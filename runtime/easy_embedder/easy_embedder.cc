// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "easy_embedder/easy_embedder.h"
#include <memory>
#include <utility>
#include "include/dart_api.h"
#include "include/dart_easy_embedder_api.h"
#include "platform/assert.h"
#include "platform/syslog.h"

namespace dart {
namespace embedder {
namespace easy {

EasyEmbedder& EasyEmbedder::instance() {
  static EasyEmbedder instance;
  return instance;
}

// Passed to Dart_SetMessageNotifyCallback.
void EasyEmbedder_MessageNotifyCallback(Dart_Isolate isolate) {
  EasyEmbedder::instance().NotifyMessage(isolate);
}

void EasyEmbedder_HandleMessage(Dart_Isolate isolate) {
  EasyEmbedder::instance().HandleMessage(isolate);
}

EasyEmbedder::~EasyEmbedder() {
  shutting_down_ = true;
  for (auto isolate : isolates_) {
    LockIsolate(isolate);
    Dart_EnterIsolate(isolate);
    Dart_SetMessageNotifyCallback(nullptr);
    Dart_ShutdownIsolate();
    UnlockIsolate(isolate);
  }

  for (auto& event_loop : event_loops_) {
    event_loop->Stop();
  }
}

void EasyEmbedder::HandleMessage(Dart_Isolate isolate) {
  if (shutting_down_) {
    // The isolate might be already shut down, so ignoring the message. More
    // fine-grained check whether a given isolate is shut down is possible, but
    // there's no obvious use-case yet.
    return;
  }
  LockIsolate(isolate);
  Dart_EnterIsolate(isolate);
  Dart_EnterScope();

  Dart_Handle handle_result = Dart_HandleMessage();

  if (Dart_IsError(handle_result)) {
    if (handle_message_error_callback_ != nullptr) {
      handle_message_error_callback_(handle_result, isolate);
    } else {
      Syslog::PrintErr("Error handling isolate message: %s",
                       Dart_GetError(handle_result));
    }
  }

  Dart_ExitScope();
  Dart_ExitIsolate();
  UnlockIsolate(isolate);
}

void EasyEmbedder::LockIsolate(Dart_Isolate isolate) {
  mutexes_[isolate].Lock();
}

void EasyEmbedder::UnlockIsolate(Dart_Isolate isolate) {
  mutexes_[isolate].Unlock();
}

void EasyEmbedder::NotifyMessage(Dart_Isolate isolate) {
  auto scheduler = schedulers_[isolate];
  if (scheduler.schedule_callback == nullptr) {
    scheduler = default_scheduler_;
  }
  if (scheduler.schedule_callback == nullptr) {
    return;
  }
  scheduler.schedule_callback(EasyEmbedder_HandleMessage, isolate,
                              scheduler.context);
}

void EventLoop_ScheduleMessageCallback(Dart_EE_MessageHandler handler,
                                       Dart_Isolate isolate,
                                       void* context) {
  reinterpret_cast<EventLoop*>(context)->ScheduleMessage(isolate);
}

EventLoop::EventLoop(EasyEmbedder* embedder) : embedder_(embedder) {}

void EventLoop::Run() {
  stopped_ = false;
  while (!stopped_) {
    Dart_Isolate isolate;
    {
      MutexLocker notifications_lock(&notifications_mutex_);
      can_pop_.Wait(&notifications_mutex_);
      if (stopped_) {
        break;
      }
      if (notifications_.empty()) {
        continue;
      }

      isolate = notifications_.front();
      notifications_.pop();
    }
    embedder_->HandleMessage(isolate);
  }
}

void EventLoop::Stop() {
  MutexLocker notifications_lock(&notifications_mutex_);
  stopped_ = true;
  can_pop_.Notify();
}

void EventLoop::ScheduleMessage(Dart_Isolate isolate) {
  MutexLocker notifications_lock(&notifications_mutex_);
  notifications_.push(isolate);
  can_pop_.Notify();
}

void EasyEmbedder::SetHandleMessageErrorCallback(
    Dart_EE_HandleMessageErrorCallback callback) {
  handle_message_error_callback_ = callback;
}

void EasyEmbedder::SetDefaultMessageScheduler(
    Dart_EE_MessageScheduler scheduler) {
  default_scheduler_ = scheduler;
}

void EasyEmbedder::SetMessageScheduler(Dart_EE_MessageScheduler scheduler,
                                       Dart_Isolate isolate) {
  schedulers_[isolate] = scheduler;
}

EventLoop* EasyEmbedder::CreateEventLoop() {
  return event_loops_.emplace_back(std::make_unique<EventLoop>(this)).get();
}

}  // namespace easy
}  // namespace embedder
}  // namespace dart
