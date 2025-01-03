#include <iostream>
#include "helpers.h"
#include "include/dart_api.h"
#include "include/dart_easy_embedder_api.h"

int main(int argc, char** argv) {
  if (argc < 3) {
    std::cerr << "Must specify two snapshot paths" << std::endl;
    std::exit(1);
  }
  char* error = nullptr;

  Dart_SnapshotData snapshot1 = AutoSnapshotFromFile(argv[1], &error);
  CheckError(error, "reading snapshot");

  Dart_SnapshotData snapshot2 = AutoSnapshotFromFile(argv[2], &error);
  CheckError(error, "reading snapshot");

  Dart_Isolate isolate1 = Dart_EE_CreateIsolate(snapshot1, &error);
  CheckError(error, "starting 1st isolate");

  Dart_Isolate isolate2 = Dart_EE_CreateIsolate(snapshot2, &error);
  CheckError(error, "starting 2nd isolate");

  Dart_EE_EnterIsolate(isolate1);
  Dart_EnterScope();

  Dart_Handle invoke_result = Dart_Invoke(
      Dart_RootLibrary(), Dart_NewStringFromCString("getValue"), 0, nullptr);
  std::string return_value = StringFromHandle(invoke_result);

  std::cout << "program1 returned: " << return_value << std::endl;
  Dart_ExitScope();
  Dart_EE_ExitIsolate();

  Dart_EE_EnterIsolate(isolate2);
  Dart_EnterScope();

  std::initializer_list<Dart_Handle> args{
      Dart_NewStringFromCString(return_value.c_str())};
  Dart_Handle invoke_result2 =
      Dart_Invoke(Dart_RootLibrary(), Dart_NewStringFromCString("printValue"),
                  1, const_cast<Dart_Handle*>(args.begin()));
  CheckError(invoke_result2);

  Dart_ExitScope();
  Dart_EE_ExitIsolate();
}
