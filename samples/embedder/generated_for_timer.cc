#include "generated_for_timer.h"
#include <cstdio>
#include <cstdlib>
#include <functional>
#include "include/dart_api.h"
#include "include/dart_easy_embedder_api.h"

namespace samples {
namespace timer {

namespace {

// Loads kernel/AOT snapshot from path depending on
// whether we use precompiled runtime.
Dart_SnapshotData AutoSnapshotFromFile(const char* path, char** error) {
  if (Dart_IsPrecompiledRuntime()) {
    return Dart_AotSnapshotFromFile(path, error);
  } else {
    return Dart_KernelFromFile(path, error);
  }
}

Dart_Handle CheckError(Dart_Handle handle, const char* context = "") {
  if (Dart_IsError(handle)) {
    fprintf(stderr, "Error %s: %s\n", context, Dart_GetError(handle));
    exit(1);
  }
  return handle;
}

int64_t IntFromHandle(Dart_Handle handle) {
  CheckError(handle, "IntFromHandle received an error");

  if (!Dart_IsInteger(handle)) {
    fprintf(stderr, "IntFromHandle handle is not an int\n");
    exit(1);
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
}  // namespace

DART_EXPORT Dart_Timer Dart_Timer_Create(Dart_SnapshotData snapshot,
                                         char** error) {
  if (!Dart_EE_Init(error) || *error != nullptr) {
    return nullptr;
  }

  Dart_Isolate isolate = Dart_EE_CreateIsolate(snapshot, error);
  return reinterpret_cast<Dart_Timer>(isolate);
}

DART_EXPORT Dart_Timer Dart_Timer_CreateForPath(const char* path,
                                                char** error) {
  fprintf(stderr, "snapshot path: %s\n", path);
  Dart_SnapshotData snapshot = AutoSnapshotFromFile(path, error);
  if (*error != nullptr) {
    fprintf(stderr, "OOPS! %s ((\n", *error);
    return nullptr;
  }
  return Dart_Timer_Create(snapshot, error);
}

// Calls `startTimer` from timer.dart
DART_EXPORT void Dart_Timer_StartTimer(Dart_Timer timer, uint32_t millis) {
  WithIsolate(reinterpret_cast<Dart_Isolate>(timer), [&]() {
    std::initializer_list<Dart_Handle> args{Dart_NewInteger(millis)};
    CheckError(
        Dart_Invoke(Dart_RootLibrary(), Dart_NewStringFromCString("startTimer"),
                    1, const_cast<Dart_Handle*>(args.begin())),
        "calling startTimer");
  });
}

DART_EXPORT void Dart_Timer_StopTimer(Dart_Timer timer) {
  WithIsolate(reinterpret_cast<Dart_Isolate>(timer), [&]() {
    CheckError(Dart_Invoke(Dart_RootLibrary(),
                           Dart_NewStringFromCString("stopTimer"), 0, nullptr),
               "calling stopTimer");
  });
}

// Calls `getTicks` from timer.dart
DART_EXPORT int64_t Dart_Timer_GetTicks(Dart_Timer timer) {
  return WithIsolate<int64_t>(reinterpret_cast<Dart_Isolate>(timer), []() {
    return IntFromHandle(Dart_Invoke(
        Dart_RootLibrary(), Dart_NewStringFromCString("getTicks"), 0, nullptr));
  });
}

// Calls `greet` from timer.dart
DART_EXPORT char* Dart_Timer_Greet(Dart_Timer timer, const char* person) {
  return WithIsolate<char*>(reinterpret_cast<Dart_Isolate>(timer), [=]() {
    std::initializer_list<Dart_Handle> args{Dart_NewStringFromCString(person)};

    Dart_Handle result = CheckError(
        Dart_Invoke(Dart_RootLibrary(), Dart_NewStringFromCString("greet"), 1,
                    const_cast<Dart_Handle*>(args.begin())));
    const char* return_value_tmp;
    CheckError(Dart_StringToCString(result, &return_value_tmp));
    return strdup(return_value_tmp);
  });
}

}  // namespace timer
}  // namespace samples
