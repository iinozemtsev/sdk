// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "bin/dartutils.h"
#include "easy_embedder/easy_embedder.h"
#include "include/dart_api.h"
#include "include/dart_easy_embedder_api.h"
#include "include/dart_embedder_api.h"
#include "platform/utils.h"

namespace dart {
namespace embedder {
namespace easy {

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
  *error = Dart_SetVMFlags(flags.size(), flags.data());
  if (*error != nullptr) {
    return false;
  }

  Dart_InitializeParams initialize_params = CreateInitializeParams();
  *error = Dart_Initialize(&initialize_params);
  if (*error != nullptr) {
    return false;
  }
  initialized_ = true;
  return true;
}

Dart_Isolate EasyEmbedder::StartIsolate(Dart_SnapshotData snapshot,
                                        char** error) {
  if (!initialized_ && !Initialize(error)) {
    return nullptr;
  }

  if (snapshot.kind != Dart_EE_SnapshotKind_Kernel) {
    *error = Utils::StrDup("DartVM supports only kernel snapshots");
  }

  Dart_IsolateFlags isolate_flags;
  Dart_IsolateFlagsInitialize(&isolate_flags);
  Dart_Isolate isolate = Dart_CreateIsolateGroupFromKernel(
      snapshot.uri, snapshot.uri, snapshot.buffer, snapshot.buffer_size,
      &isolate_flags, nullptr, nullptr, error);
  if (*error != nullptr) {
    return nullptr;
  }

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
  // Technically, it is not needed to load library from kernel: it is already
  // loaded after Dart_CreateIsolateGroupFromKernel, the problem is we don't
  // know its URI (it is not related to snapshot->uri and depends on where the
  // kernel snapshot was built, e.g. file:///Users/user/samples/hello.dart)
  Dart_Handle library =
      Dart_LoadScriptFromKernel(snapshot.buffer, snapshot.buffer_size);

  if (Dart_IsError(library)) {
    Dart_ShutdownIsolate();
    *error = Utils::StrDup(Dart_GetError(library));
    return nullptr;
  }

  Dart_ExitScope();
  Dart_ExitIsolate();
  return isolates_.emplace_back(isolate);
}
}  // namespace easy
}  // namespace embedder
}  // namespace dart
