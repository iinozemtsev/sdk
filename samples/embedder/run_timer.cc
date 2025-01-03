#include <iostream>
#include <thread>
#include "helpers.h"
#include "include/dart_api.h"
#include "include/dart_easy_embedder_api.h"

// Calls `startTimer` from timer.dart
void StartTimer(Dart_Isolate isolate, uint32_t millis) {
  WithIsolate(isolate, [&]() {
    std::initializer_list<Dart_Handle> args{Dart_NewInteger(millis)};
    CheckError(
        Dart_Invoke(Dart_RootLibrary(), Dart_NewStringFromCString("startTimer"),
                    1, const_cast<Dart_Handle*>(args.begin())),
        "calling startTimer");
  });
}

// Calls `stopTimer` from timer.dart
void StopTimer(Dart_Isolate isolate) {
  WithIsolate(isolate, [&]() {
    CheckError(Dart_Invoke(Dart_RootLibrary(),
                           Dart_NewStringFromCString("stopTimer"), 0, nullptr),
               "calling stopTimer");
  });
}

// Gets `ticks` from timer.dart
int64_t GetTicks(Dart_Isolate isolate) {
  return WithIsolate<int64_t>(isolate, []() {
    return IntFromHandle(
        Dart_GetField(Dart_RootLibrary(), Dart_NewStringFromCString("ticks")));
  });
}

int main(int argc, char** argv) {
  if (argc == 1) {
    std::cerr << "Must specify snapshot path" << std::endl;
    std::exit(1);
  }
  char* error = nullptr;

  // Start an event loop on a separate thread and use it as a default
  // scheduler.
  auto event_loop = Dart_EE_CreateEventLoop();
  std::thread event_loop_thread(Dart_EE_RunEventLoop, event_loop);
  Dart_EE_SetDefaultMessageScheduler(event_loop);

  // Load snapshot and create an isolate
  Dart_SnapshotData snapshot_data = AutoSnapshotFromFile(argv[1], &error);
  CheckError(error, "reading snapshot");
  Dart_Isolate isolate = Dart_EE_CreateIsolate(snapshot_data, &error);
  CheckError(error, "creating isolate");

  // Call Dart function to start a timer.
  StartTimer(isolate, 1);

  // Wait a bit.
  std::this_thread::sleep_for(std::chrono::milliseconds(100));

  // Stop the timer.
  StopTimer(isolate);

  // Get timer value.
  std::cout << "Ticks: " << GetTicks(isolate) << std::endl;

  // Stop event loop.
  Dart_EE_StopEventLoop(event_loop);
  event_loop_thread.join();
}
