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

  IsolateHandle* IsolateGroupFromKernel(const SnapshotData& snapshot_data,
                                        char** error);

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

class GeneratedForSendString {
 public:
  GeneratedForSendString(IsolateHandle* isolate) : isolate_(isolate){};

  IsolateHandle* isolate_;

  DartResult<std::string> gimmeString() {
    std::string error;
    Dart_EnterIsolate(isolate_->isolate_);
    Dart_EnterScope();
    Dart_Handle invoke_result =
        Dart_Invoke(isolate_->library_,
                    Dart_NewStringFromCString("gimmeString"), 0, nullptr);
    if (Dart_IsError(invoke_result)) {
      error = Utils::StrDup(Dart_GetError(invoke_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return DartResult<std::string>::Error(error);
    }

    if (!Dart_IsString(invoke_result)) {
      Dart_ExitScope();
      Dart_ExitIsolate();
      return DartResult<std::string>::Error("Return type is not string ");
    }

    const char* return_value;
    Dart_Handle to_string_result =
        Dart_StringToCString(invoke_result, &return_value);
    if (Dart_IsError(to_string_result)) {
      error = Utils::StrDup(Dart_GetError(to_string_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return DartResult<std::string>::Error(error);
    }
    auto result = DartResult<std::string>::Success(std::string(return_value));
    Dart_ExitScope();
    Dart_ExitIsolate();
    return result;
  }

  DartResult<std::string> greet(std::string_view person) {
    std::string error;
    Dart_EnterIsolate(isolate_->isolate_);
    Dart_EnterScope();
    std::initializer_list<Dart_Handle> args{
        Dart_NewStringFromCString(std::string(person).c_str())};
    Dart_Handle invoke_result =
        Dart_Invoke(isolate_->library_, Dart_NewStringFromCString("greet"),
                    args.size(), const_cast<Dart_Handle*>(args.begin()));
    if (Dart_IsError(invoke_result)) {
      error = Utils::StrDup(Dart_GetError(invoke_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return DartResult<std::string>::Error(error);
    }

    if (!Dart_IsString(invoke_result)) {
      Dart_ExitScope();
      Dart_ExitIsolate();
      return DartResult<std::string>::Error("Return type is not string ");
    }

    const char* return_value;
    Dart_Handle dart_result =
        Dart_StringToCString(invoke_result, &return_value);
    if (Dart_IsError(dart_result)) {
      error = Utils::StrDup(Dart_GetError(dart_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return DartResult<std::string>::Error(error);
    }
    auto result = DartResult<std::string>::Success(std::string(return_value));
    Dart_ExitScope();
    Dart_ExitIsolate();
    return result;
  }
};

}  // namespace dart::embedder::simple

#endif  // RUNTIME_BIN_SIMPLE_EMBEDDER_H_
