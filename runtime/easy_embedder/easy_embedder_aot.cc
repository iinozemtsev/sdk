// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <cstdint>
#include <memory>
#include "bin/dartutils.h"
#include "bin/elf_loader.h"
#include "easy_embedder/easy_embedder.h"
#include "include/dart_api.h"
#include "include/dart_easy_embedder_api.h"
#include "include/dart_embedder_api.h"
#include "platform/utils.h"

namespace dart {
namespace embedder {
namespace easy {

// State specific to AOT Dart VM.
struct AotState {
  std::vector<Dart_LoadedElf*> loaded_elfs;
  bool first_isolate_started;

  AotState() : first_isolate_started(false) {}

  ~AotState() {
    // TODO(iinozemtsev): should we unload it on isolate exit instead?
    for (auto* loaded_elf : loaded_elfs) {
      Dart_UnloadELF(loaded_elf);
    }
  }
};

AotState aot_state;

Dart_InitializeParams CreateInitializeParams() {
  Dart_InitializeParams params;
  memset(&params, 0, sizeof(params));
  params.version = DART_INITIALIZE_PARAMS_CURRENT_VERSION;
  params.shutdown_isolate = nullptr;
  params.create_group = nullptr;
  return params;
}

bool EasyEmbedder::Initialize(char** error) {
  if (initialized_) {
    return true;
  }
  if (!dart::embedder::InitOnce(error)) {
    return false;
  }

  std::vector<const char*> flags{};
  flags.push_back("--precompilation");
  *error = Dart_SetVMFlags(flags.size(), flags.data());

  if (*error != nullptr) {
    return false;
  }

  initialized_ = true;
  return true;
}

Dart_Isolate EasyEmbedder::StartIsolate(Dart_SnapshotData snapshot,
                                        char** error) {
  if (!Dart_IsPrecompiledRuntime()) {
    *error = Utils::StrDup("AOT Dart VM requires precompiled runtime.");
    return nullptr;
  }

  if (!initialized_ && !Initialize(error)) {
    return nullptr;
  }

  if (snapshot.kind != Dart_EE_SnapshotKind_AOT) {
    *error = Utils::StrDup("AOT Dart VM supports only AOT snapshots");
    return nullptr;
  }

  const uint8_t* vm_snapshot_data;
  const uint8_t* vm_snapshot_instructions;
  const uint8_t* vm_isolate_data;
  const uint8_t* vm_isolate_instructions;

  Dart_LoadedElf* loaded_elf = Dart_LoadELF_Memory(
      snapshot.buffer, snapshot.buffer_size, const_cast<const char**>(error),
      &vm_snapshot_data, &vm_snapshot_instructions, &vm_isolate_data,
      &vm_isolate_instructions);
  if (*error != nullptr) {
    return nullptr;
  }
  aot_state.loaded_elfs.emplace_back(loaded_elf);

  if (!aot_state.first_isolate_started) {
    Dart_InitializeParams initialize_params = CreateInitializeParams();
    initialize_params.vm_snapshot_data = vm_snapshot_data;
    initialize_params.vm_snapshot_instructions = vm_snapshot_instructions;
    *error = Dart_Initialize(&initialize_params);
    if (*error != nullptr) {
      return nullptr;
    }
    aot_state.first_isolate_started = true;
  }

  // Now we can start an isolate.
  Dart_IsolateFlags isolate_flags;
  Dart_IsolateFlagsInitialize(&isolate_flags);

  // Automatically sets the root library for the isolate.
  Dart_Isolate isolate = Dart_CreateIsolateGroup(
      snapshot.uri, snapshot.uri, vm_isolate_data, vm_isolate_instructions,
      &isolate_flags, nullptr, nullptr, error);

  Dart_SetMessageNotifyCallback(EasyEmbedder_MessageNotifyCallback);

  Dart_EnterScope();

  // In fact, this call initializes core libraries, (e.g. `print`
  // doesn't work without it).
  Dart_Handle core_libs_result =
      bin::DartUtils::PrepareForScriptLoading(false, false);
  if (Dart_IsError(core_libs_result)) {
    Dart_ShutdownIsolate();
    *error = Utils::StrDup(Dart_GetError(core_libs_result));
    return nullptr;
  }

  Dart_ExitScope();
  Dart_ExitIsolate();
  return isolates_.emplace_back(isolate);
}
}  // namespace easy
}  // namespace embedder
}  // namespace dart
