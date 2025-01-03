// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef RUNTIME_EASY_EMBEDDER_EASY_EMBEDDER_H_
#define RUNTIME_EASY_EMBEDDER_EASY_EMBEDDER_H_

#include <memory>
#include <queue>
#include <unordered_map>
#include <vector>
#include "include/dart_easy_embedder_api.h"
#include "platform/synchronization.h"
#include "vm/lockers.h"

namespace dart {
namespace embedder {
namespace easy {

// Passed to Dart_SetMessageNotifyCallback.void
void EasyEmbedder_MessageNotifyCallback(Dart_Isolate isolate);
void EasyEmbedder_HandleMessage(Dart_Isolate isolate);

class EventLoop;

class EasyEmbedder {
 public:
  ~EasyEmbedder();
  Dart_Isolate StartIsolate(const Dart_SnapshotData snapshot, char** error);

  void LockIsolate(Dart_Isolate isolate);
  void UnlockIsolate(Dart_Isolate isolate);
  void NotifyMessage(Dart_Isolate isolate);
  void HandleMessage(Dart_Isolate isolate);

  void SetHandleMessageErrorCallback(
      Dart_EE_HandleMessageErrorCallback callback);
  void SetDefaultMessageScheduler(Dart_EE_MessageScheduler scheduler);
  void SetMessageScheduler(Dart_EE_MessageScheduler scheduler,
                           Dart_Isolate isolate);
  EventLoop* CreateEventLoop();
  bool Initialize(char** error);

  static EasyEmbedder& instance();

 private:
  std::atomic<bool> shutting_down_ = false;
  bool initialized_ = false;
  std::vector<Dart_Isolate> isolates_;
  std::vector<std::unique_ptr<EventLoop>> event_loops_;
  std::unordered_map<Dart_Isolate, Mutex> mutexes_;

  Dart_EE_MessageScheduler default_scheduler_;
  std::unordered_map<Dart_Isolate, Dart_EE_MessageScheduler> schedulers_;
  Dart_EE_HandleMessageErrorCallback handle_message_error_callback_;

  static EasyEmbedder instance_;
};

void EventLoop_ScheduleMessageCallback(Dart_EE_MessageHandler handler,
                                       Dart_Isolate isolate,
                                       void* context);

class EventLoop {
 public:
  explicit EventLoop(EasyEmbedder* embedder);
  void Run();
  void Stop();
  void ScheduleMessage(Dart_Isolate isolate);

 private:
  std::queue<Dart_Isolate> notifications_;
  ConditionVariable can_pop_;
  Mutex notifications_mutex_;
  std::atomic<bool> stopped_;
  EasyEmbedder* embedder_;
};

}  // namespace easy
}  // namespace embedder
}  // namespace dart
#endif  // RUNTIME_EASY_EMBEDDER_EASY_EMBEDDER_H_
