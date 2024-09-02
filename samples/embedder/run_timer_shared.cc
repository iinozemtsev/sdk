#include <future>
#include <iostream>
#include <thread>
#include "generated_for_timer.h"
#include "include/dart_api.h"
#include "include/dart_easy_embedder_api.h"

void ScheduleDartMessage(Dart_EE_MessageHandler handler,
                         Dart_Isolate isolate,
                         void* context) {
  // std::thread(handler, isolate).detach();
  std::ignore = std::async(handler, isolate);
}

int main(int argc, char** argv) {
  if (argc == 1) {
    std::cerr << "Must specify snapshot path" << std::endl;
    std::exit(1);
  }

  char* error = nullptr;
  // Dart_SnapshotData snapshot = Dart_KernelFromFile(argv[1], &error);
  // if (error != nullptr) {
  //   std::cerr << "Error reading snapshot: " << error << std::endl;
  // }

  // auto dart_timer = Dart_Timer_Create(&snapshot, &error);
  auto dart_timer = Dart_Timer_CreateForPath(argv[1], &error);
  if (error != nullptr) {
    std::cerr << "Error creating Dart timer: " << error << std::endl;
  }

  Dart_EE_SetDefaultMessageScheduler({ScheduleDartMessage, nullptr});

  // Call Dart function to start a timer.
  Dart_Timer_StartTimer(dart_timer, 1);

  // Wait a bit.
  std::this_thread::sleep_for(std::chrono::milliseconds(100));

  // Stop timer.
  Dart_Timer_StopTimer(dart_timer);

  // Get timer value.
  std::cout << "Ticks: " << Dart_Timer_GetTicks(dart_timer) << std::endl;

  // Wait a bit more.
  std::this_thread::sleep_for(std::chrono::milliseconds(100));

  // Get timer value again.
  std::cout << "Ticks after stopping: " << Dart_Timer_GetTicks(dart_timer)
            << std::endl;

  std::cout << "Greeting from Dart: " << Dart_Timer_Greet(dart_timer, "Ivan")
            << std::endl;
}
