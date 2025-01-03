// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef RUNTIME_EASY_EMBEDDER_INCLUDE_DART_EASY_EMBEDDER_API_H_
#define RUNTIME_EASY_EMBEDDER_INCLUDE_DART_EASY_EMBEDDER_API_H_
#include "include/dart_api.h"

// Initializes Dart VM.
//
// Returns false on error, in which case error would contain error
// message.
//
// TODO(iinozemtsev): Do we need this at all?
DART_EXPORT bool Dart_EE_Init(char** error);

typedef enum {
  Dart_EE_SnapshotKind_Kernel,
  Dart_EE_SnapshotKind_AOT,
} Dart_EE_SnapshotKind;

typedef struct Dart_SnapshotData {
  char* uri;
  uint8_t* buffer;
  intptr_t buffer_size;
  Dart_EE_SnapshotKind kind;
} Dart_SnapshotData;

DART_EXPORT Dart_Isolate Dart_EE_CreateIsolate(Dart_SnapshotData snapshot_data,
                                               char** error);

// Lock-guarded alternatives to Dart_EnterIsolate/Dart_ExitIsolate.
// Blocks until the isolate is available for entering.
DART_EXPORT void Dart_EE_EnterIsolate(Dart_Isolate isolate);
// Exits current isolate and unlocks it.
DART_EXPORT void Dart_EE_ExitIsolate();

typedef void (*Dart_EE_HandleMessageErrorCallback)(
    Dart_Handle error,
    Dart_Isolate destination_isolate);

DART_EXPORT void Dart_EE_SetHandleMessageErrorCallback(
    Dart_EE_HandleMessageErrorCallback handle_message_error_callback);

// Handles a single message for an isolate.
//
// Users aren't supposed to create their own message handlers, instead
// it is passed to Dart_EE_ScheduleMessageCallback.
typedef void (*Dart_EE_MessageHandler)(Dart_Isolate isolate);

// Message scheduling callback.
//
// Dart Embedder calls this callback whenever there's a new message
// for an isolate, and the callback should schedule an execution of
// provided handler.
typedef void (*Dart_EE_ScheduleMessageCallback)(Dart_EE_MessageHandler handler,
                                                Dart_Isolate isolate,
                                                void* context);

typedef struct Dart_EE_MessageScheduler {
  Dart_EE_ScheduleMessageCallback schedule_callback;
  void* context;
} Dart_EE_MessageScheduler;

//
DART_EXPORT void Dart_EE_SetDefaultMessageScheduler(
    Dart_EE_MessageScheduler scheduler);

DART_EXPORT void Dart_EE_SetMessageScheduler(Dart_EE_MessageScheduler scheduler,
                                             Dart_Isolate isolate);

// Event loop is a message scheduler, which stores
// isolate message notifications in a queue.
//
// One event loop can handle messages for multiple isolates.
//
// Dart_EE_RunEventLoop must be called on a separate thread
// for actual message handling.
DART_EXPORT Dart_EE_MessageScheduler Dart_EE_CreateEventLoop();
DART_EXPORT void Dart_EE_RunEventLoop(Dart_EE_MessageScheduler event_loop);
DART_EXPORT void Dart_EE_StopEventLoop(Dart_EE_MessageScheduler event_loop);

// Quality of life helpers, non-essential.
//
// Caller should not free the buffer and the uri.
DART_EXPORT Dart_SnapshotData Dart_KernelFromFile(const char* path,
                                                  char** error);
DART_EXPORT Dart_SnapshotData Dart_AotSnapshotFromFile(const char* path,
                                                       char** error);

#endif  // RUNTIME_EASY_EMBEDDER_INCLUDE_DART_EASY_EMBEDDER_API_H_
