#include <future>
#include <iostream>
#include <thread>
#include "helpers.h"
#include "include/dart_api.h"
#include "include/dart_engine.h"
#include "include/dart_native_api.h"

void ScheduleDartMessage(Dart_Isolate isolate, void* context) {
  std::thread(DartEngine_HandleMessage, isolate).detach();
}

std::promise<std::string> result_promise;

void HandlePortMessage(Dart_Port dest_port, Dart_CObject* message) {
  std::cout << "HandlePortMessage received a message" << std::endl;
  // Message is destroyed once this method completes.
  if (message->type != Dart_CObject_kString) {
    std::cerr << "Expected string, got " << message->type << std::endl;
    std::exit(1);
  }
  result_promise.set_value(std::string(message->value.as_string));
}

int main(int argc, char** argv) {
  if (argc < 2) {
    std::cerr << "Must specify snapshot path" << std::endl;
  }

  char* error = nullptr;

  DartEngine_MessageScheduler scheduler{ScheduleDartMessage, nullptr};
  DartEngine_SetDefaultMessageScheduler(scheduler);

  DartEngine_SnapshotData snapshot = AutoSnapshotFromFile(argv[1], &error);
  CheckError(error, "reading snapshot");

  Dart_Isolate isolate = DartEngine_CreateIsolate(snapshot, &error);
  CheckError(error, "starting an isolate");

  Dart_Port result_port =
      Dart_NewNativePort("compute_port", HandlePortMessage, true);
  DartEngine_AcquireIsolate(isolate);
  Dart_EnterScope();

  std::initializer_list<Dart_Handle> args{
      Dart_NewInteger(100), Dart_NewInteger(10), Dart_NewSendPort(result_port)};

  std::cout << "Calling compute..." << std::endl;
  Dart_Handle computation_result =
      Dart_Invoke(Dart_RootLibrary(), Dart_NewStringFromCString("compute"), 3,
                  const_cast<Dart_Handle*>(args.begin()));
  std::cout << "Compute is future: " << Dart_IsFuture(computation_result)
            << std::endl;

  Dart_ExitScope();
  DartEngine_ReleaseIsolate();

  std::cout << "Waiting for compute result..." << std::endl;
  std::string compute_result = result_promise.get_future().get();
  std::cout << "Compute result: " << compute_result << std::endl;

  DartEngine_Shutdown();
}
