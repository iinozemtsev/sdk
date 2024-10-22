// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef RUNTIME_BIN_SIMPLE_EMBEDDER_H_
#define RUNTIME_BIN_SIMPLE_EMBEDDER_H_

#include <cstdint>
#include <string>
#include <type_traits>
#include <vector>
#include "include/dart_api.h"
#include "platform/assert.h"
#include "platform/utils.h"

namespace dart::embedder::simple {

struct SnapshotData {
  std::string name;
  const char* bytes;
  uint64_t size;
};

class DartEmbedder;

class IsolateHandle {
 public:
  IsolateHandle(Dart_Isolate isolate, Dart_Handle library)
      : isolate_(isolate), library_(library) {}

  Dart_Isolate isolate_;
  Dart_Handle library_;
};

class DartEmbedder {
 public:
  bool Init(char** error);

  IsolateHandle* IsolateGroupFromKernel(
      const SnapshotData& snapshot_data,
      char** error,
      Dart_MessageNotifyCallback message_notify_callback,
      void* isolate_data);

  void Shutdown();

 private:
  bool initialized_;
  std::vector<IsolateHandle> isolates_;
};

// Runs kernel snapshot till completion.
bool Run(const char* snapshot_data,
         uint64_t snapshot_length,
         // const char* vm_platform_snapshot_data,
         // uint64_t vm_platform_snapshot_length,
         char** error);

template <typename T>
struct DartResult {
  T value;
  std::string error;
  bool is_error;

  T& value_or_die() {
    if (is_error) {
      FATAL("DartResult has an error: %s", error.c_str());
    }
    return value;
  }

  static DartResult<T> Error(std::string_view error) {
    DartResult<T> result;
    result.error = std::string(error);
    result.is_error = true;
    return result;
  }

  static DartResult<T> Success(T&& value) {
    DartResult<T> result;
    result.value = value;
    result.is_error = false;
    return result;
  }

  static DartResult<T> Success(const T& value) {
    DartResult<T> result;
    result.value = value;
    result.is_error = false;
    return result;
  }
};

// Void
struct VoidDartResult {
  std::string error;
  bool is_error;

  void check_ok() {
    if (is_error) {
      FATAL("DartResult has an error: %s", error.c_str());
    }
  }

  static VoidDartResult Error(std::string_view error) {
    VoidDartResult result;
    result.error = std::string(error);
    result.is_error = true;
    return result;
  }

  static VoidDartResult Success() {
    VoidDartResult result;
    result.is_error = false;
    return result;
  }
};

}  // namespace dart::embedder::simple

#endif  // RUNTIME_BIN_SIMPLE_EMBEDDER_H_
