// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <cstdint>
#include <memory>
#include <vector>
#include "easy_embedder/easy_embedder.h"
#include "include/dart_api.h"
#include "include/dart_easy_embedder_api.h"
#include "platform/utils.h"

namespace dart {
namespace embedder {
namespace easy {

DART_EXPORT bool Dart_EE_Init(char** error) {
  return EasyEmbedder::instance().Initialize(error);
}

std::vector<void*> snapshot_buffers;

Dart_SnapshotData Dart_SnapshotDataFromFile(const char* path,
                                            Dart_EE_SnapshotKind snapshot_kind,
                                            char** error) {
  Dart_SnapshotData result;
  result.kind = snapshot_kind;
  result.uri = Utils::SCreate("file://%s", path);
  FILE* file = fopen(path, "rb");
  if (file == nullptr) {
    *error = Utils::SCreate("Error %d", errno);
    return result;
  }

  fseek(file, 0, SEEK_END);
  size_t size = ftell(file);
  rewind(file);

  char* buffer = reinterpret_cast<char*>(malloc(sizeof(char) * (size + 1)));
  buffer[size] = 0;

  size_t bytes_read = fread(buffer, 1, size, file);
  fclose(file);
  if (bytes_read != size) {
    *error = Utils::SCreate("Error reading %s: read %zu bytes instead of %zu",
                            path, bytes_read, size);
    return result;
  }

  result.buffer_size = size;
  result.buffer = reinterpret_cast<uint8_t*>(buffer);

  snapshot_buffers.emplace_back(result.buffer);
  snapshot_buffers.emplace_back(result.uri);

  return result;
}

DART_EXPORT Dart_SnapshotData Dart_KernelFromFile(const char* path,
                                                  char** error) {
  return Dart_SnapshotDataFromFile(path, Dart_EE_SnapshotKind_Kernel, error);
}

DART_EXPORT Dart_SnapshotData Dart_AotSnapshotFromFile(const char* path,
                                                       char** error) {
  return Dart_SnapshotDataFromFile(path, Dart_EE_SnapshotKind_AOT, error);
}

DART_EXPORT Dart_Isolate Dart_EE_CreateIsolate(Dart_SnapshotData snapshot_data,
                                               char** error) {
  return EasyEmbedder::instance().StartIsolate(snapshot_data, error);
}

DART_EXPORT void Dart_EE_EnterIsolate(Dart_Isolate isolate) {
  EasyEmbedder::instance().LockIsolate(isolate);
  Dart_EnterIsolate(isolate);
}

DART_EXPORT void Dart_EE_ExitIsolate() {
  Dart_Isolate current = Dart_CurrentIsolate();
  ASSERT(current != nullptr);
  Dart_ExitIsolate();
  EasyEmbedder::instance().UnlockIsolate(current);
}

DART_EXPORT void Dart_EE_SetHandleMessageErrorCallback(
    Dart_EE_HandleMessageErrorCallback handle_message_error_callback) {
  EasyEmbedder::instance().SetHandleMessageErrorCallback(
      handle_message_error_callback);
}

DART_EXPORT void Dart_EE_SetDefaultMessageScheduler(
    Dart_EE_MessageScheduler scheduler) {
  EasyEmbedder::instance().SetDefaultMessageScheduler(scheduler);
}

DART_EXPORT void Dart_EE_SetMessageScheduler(Dart_EE_MessageScheduler scheduler,
                                             Dart_Isolate isolate) {
  EasyEmbedder::instance().SetMessageScheduler(scheduler, isolate);
}

DART_EXPORT Dart_EE_MessageScheduler Dart_EE_CreateEventLoop() {
  auto event_loop = EasyEmbedder::instance().CreateEventLoop();
  return Dart_EE_MessageScheduler{EventLoop_ScheduleMessageCallback,
                                  event_loop};
}

DART_EXPORT void Dart_EE_RunEventLoop(Dart_EE_MessageScheduler scheduler) {
  reinterpret_cast<EventLoop*>(scheduler.context)->Run();
}

DART_EXPORT void Dart_EE_StopEventLoop(Dart_EE_MessageScheduler scheduler) {
  reinterpret_cast<EventLoop*>(scheduler.context)->Stop();
}

}  // namespace easy
}  // namespace embedder
}  // namespace dart
