#ifndef SAMPLES_EMBEDDER_HELPERS_H_
#define SAMPLES_EMBEDDER_HELPERS_H_

#include <functional>
#include <iostream>
#include <string>
#include <string_view>
#include "include/dart_api.h"
#include "include/dart_easy_embedder_api.h"

// Loads kernel/AOT snapshot from path depending on
// whether we use precompiled runtime.
Dart_SnapshotData AutoSnapshotFromFile(std::string_view path, char** error) {
  std::string path_string(path);
  if (Dart_IsPrecompiledRuntime()) {
    return Dart_AotSnapshotFromFile(path_string.c_str(), error);
  } else {
    return Dart_KernelFromFile(path_string.c_str(), error);
  }
}

void CheckError(char* error, std::string_view context = "") {
  if (error != nullptr) {
    std::cerr << "Error " << context << ": " << error << std::endl;
    std::exit(1);
  }
}

Dart_Handle CheckError(Dart_Handle handle, std::string_view context = "") {
  if (Dart_IsError(handle)) {
    std::cerr << "Error " << context << ": " << Dart_GetError(handle)
              << std::endl;
    std::exit(1);
  }
  return handle;
}

std::string StringFromHandle(Dart_Handle handle) {
  CheckError(handle, "StringFromHandle received an error");

  if (!Dart_IsString(handle)) {
    std::cerr << "StringFromHandle handle is not a string" << std::endl;
    std::exit(1);
  }

  const char* return_value_tmp;
  Dart_Handle to_string_result =
      Dart_StringToCString(handle, &return_value_tmp);
  CheckError(to_string_result, "Dart_StringToCString");

  return std::string(return_value_tmp);
}

int64_t IntFromHandle(Dart_Handle handle) {
  CheckError(handle, "IntFromHandle received an error");

  if (!Dart_IsInteger(handle)) {
    std::cerr << "IntFromHandle handle is not an int" << std::endl;
    std::exit(1);
  }

  int64_t result;
  Dart_Handle to_int64_result = Dart_IntegerToInt64(handle, &result);
  CheckError(to_int64_result, "Dart_IntegerToInt64");
  return result;
}

template <typename T>
T WithIsolate(Dart_Isolate isolate, std::function<T()> body) {
  Dart_EE_EnterIsolate(isolate);
  Dart_EnterScope();
  T result = body();
  Dart_ExitScope();
  Dart_EE_ExitIsolate();
  return result;
}

void WithIsolate(Dart_Isolate isolate, std::function<void()> body) {
  Dart_EE_EnterIsolate(isolate);
  Dart_EnterScope();
  body();
  Dart_ExitScope();
  Dart_EE_ExitIsolate();
}

#endif /* SAMPLES_EMBEDDER_HELPERS_H_ */
