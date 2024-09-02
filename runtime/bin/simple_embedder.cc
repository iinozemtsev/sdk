#include "simple_embedder.h"
#include <chrono>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <thread>
#include <vector>
#include "bin/dartutils.h"
#include "include/dart_api.h"
#include "include/dart_embedder_api.h"
#include "platform/globals.h"
#include "platform/utils.h"

namespace dart::embedder::simple {

namespace {

void LOG(std::string_view message) {
  std::cout << message << std::endl;
}

void OnIsolateShutdown(void* isolate_group_data, void* callback_data) {}

// const char* _vm_platform_snapshot_data;
// uint64_t _vm_platform_snapshot_length;

Dart_Isolate CreateIsolateCallback(const char* script_uri,
                                   const char* main,
                                   const char* package_root,
                                   const char* package_config,
                                   Dart_IsolateFlags* flags,
                                   void* isolate_data,
                                   char** error) {
  dart::embedder::IsolateCreationData isolate_creation_data = {
      script_uri,
      main,
      flags,
      isolate_data,
  };

  dart::embedder::VmServiceConfiguration service_config = {
      .ip = "::",
      .port = dart::embedder::VmServiceConfiguration::kDoNotAutoStartHttpServer,
      .dev_mode = true,
      .deterministic = false,
      .disable_auth_codes = false,
  };
  USE(isolate_creation_data);
  USE(service_config);
  std::cout << "CreateIsolate Callback invoked"
            << " script_uri: " << script_uri << " main: " << main << std::endl;

  Dart_Isolate isolate = nullptr;

  // if (strcmp(script_uri, DART_VM_SERVICE_ISOLATE_NAME) == 0) {
  //   isolate = dart::embedder::CreateVmServiceIsolateFromKernel(
  //       isolate_creation_data, service_config,
  //       reinterpret_cast<const uint8_t*>(_vm_platform_snapshot_data),
  //       _vm_platform_snapshot_length, error);

  //   if (isolate == nullptr) {
  //     return nullptr;
  //   }
  //   std::cout << "Started VM Service Isolate" << std::endl;
  //   // instance->vm_service_isolate = isolate;
  // }

  std::cout << "CreateIsolateCallback finished" << std::endl;
  return isolate;
}

Dart_InitializeParams CreateInitializeParams() {
  Dart_InitializeParams params;
  memset(&params, 0, sizeof(params));
  params.version = DART_INITIALIZE_PARAMS_CURRENT_VERSION;
  params.shutdown_isolate = &OnIsolateShutdown;
  params.create_group = &CreateIsolateCallback;
  return params;
}

}  // namespace

bool Run(const char* snapshot_data,
         uint64_t snapshot_length,
         // const char* vm_platform_snapshot_data,
         // uint64_t vm_platform_snapshot_length,
         char** error) {
  // _vm_platform_snapshot_data = vm_platform_snapshot_data;
  // _vm_platform_snapshot_length = vm_platform_snapshot_length;
  std::cout << "Calling InitOnce" << std::endl;
  if (!dart::embedder::InitOnce(error)) {
    return false;
  }
  std::cout << "InitOnce succeeded" << std::endl;

  std::cout << "Creating InitializeParams" << std::endl;
  Dart_InitializeParams initialize_params = CreateInitializeParams();
  std::cout << "Created InitializeParams" << std::endl;

  std::vector<const char*> flags{};
  std::cout << "Setting VM Flags" << std::endl;
  *error = Dart_SetVMFlags(flags.size(), flags.data());
  if (*error != nullptr) {
    return false;
  }

  std::cout << "Calling Dart_Initialize" << std::endl;
  *error = Dart_Initialize(&initialize_params);

  if (*error != nullptr) {
    return false;
  }

  std::cout << "Dart_Initialize succeeded" << std::endl;

  Dart_IsolateFlags isolate_flags;
  // Starting isolate.
  std::cout << "Creating Isolate Group from Kernel" << std::endl;
  Dart_Isolate isolate = Dart_CreateIsolateGroupFromKernel(
      /*script_uri=*/"file:///dill",
      /*name=*/"send_string",
      /*kernel_buffer=*/reinterpret_cast<const uint8_t*>(snapshot_data),
      snapshot_length,
      /*flags=*/&isolate_flags,
      /*isolate_group_data=*/nullptr,
      /*isolate_data=*/nullptr, error);
  if (isolate == nullptr) {
    return false;
  }
  USE(isolate);
  LOG("Entering scope");
  Dart_EnterScope();
  LOG("Entered scope");
  LOG("Preparing for script loading");
  Dart_Handle core_libs_result =
      bin::DartUtils::PrepareForScriptLoading(false, false);
  LOG("Prepared for script loading");
  if (Dart_IsError(core_libs_result)) {
    Dart_ShutdownIsolate();
    *error = Utils::StrDup(Dart_GetError(core_libs_result));
    return false;
  }

  Dart_Handle library = Dart_LoadLibraryFromKernel(
      reinterpret_cast<const uint8_t*>(snapshot_data), snapshot_length);
  if (Dart_IsError(library)) {
    Dart_ShutdownIsolate();
    *error = Utils::StrDup(Dart_GetError(core_libs_result));
    return false;
  }
  LOG("Loaded library");
  Dart_Handle invoke_result =
      Dart_Invoke(library, Dart_NewStringFromCString("helloWorld"), 0, nullptr);
  if (Dart_IsError(invoke_result)) {
    Dart_ShutdownIsolate();
    *error = Utils::StrDup(Dart_GetError(invoke_result));
    return false;
  }
  Dart_ShutdownIsolate();
  //  std::this_thread::sleep_for(std::chrono::milliseconds(1000));
  return true;
}

bool DartEmbedder::Init(char** error) {
  if (initialized_) {
    return true;
  }

  std::cout << "Calling InitOnce" << std::endl;
  if (!dart::embedder::InitOnce(error)) {
    return false;
  }
  std::cout << "InitOnce succeeded" << std::endl;

  std::cout << "Creating InitializeParams" << std::endl;
  Dart_InitializeParams initialize_params = CreateInitializeParams();
  std::cout << "Created InitializeParams" << std::endl;

  std::vector<const char*> flags{};
  std::cout << "Setting VM Flags" << std::endl;
  *error = Dart_SetVMFlags(flags.size(), flags.data());
  if (*error != nullptr) {
    return false;
  }

  std::cout << "Calling Dart_Initialize" << std::endl;
  *error = Dart_Initialize(&initialize_params);

  if (*error != nullptr) {
    return false;
  }

  std::cout << "Dart_Initialize succeeded" << std::endl;
  initialized_ = true;
  return true;
}

IsolateHandle* DartEmbedder::IsolateGroupFromKernel(
    const SnapshotData& snapshot_data,
    char** error) {
  if (!initialized_) {
    *error = Utils::StrDup("Embedder is not initialized");
    return nullptr;
  }

  Dart_IsolateFlags isolate_flags;
  // Starting isolate.
  std::cout << "Creating Isolate Group from Kernel" << std::endl;
  Dart_Isolate isolate = Dart_CreateIsolateGroupFromKernel(
      /*script_uri=*/"file:///dill",
      /*name=*/"send_string",
      /*kernel_buffer=*/reinterpret_cast<const uint8_t*>(snapshot_data.bytes),
      snapshot_data.size,
      /*flags=*/&isolate_flags,
      /*isolate_group_data=*/nullptr,
      /*isolate_data=*/nullptr, error);
  if (isolate == nullptr) {
    return nullptr;
  }
  USE(isolate);
  LOG("Entering scope");
  Dart_EnterScope();
  LOG("Entered scope");
  LOG("Preparing for script loading");
  Dart_Handle core_libs_result =
      bin::DartUtils::PrepareForScriptLoading(false, false);
  LOG("Prepared for script loading");
  if (Dart_IsError(core_libs_result)) {
    Dart_ShutdownIsolate();
    *error = Utils::StrDup(Dart_GetError(core_libs_result));
    return nullptr;
  }

  Dart_Handle library = Dart_LoadLibraryFromKernel(
      reinterpret_cast<const uint8_t*>(snapshot_data.bytes),
      snapshot_data.size);

  if (Dart_IsError(library)) {
    Dart_ShutdownIsolate();
    *error = Utils::StrDup(Dart_GetError(core_libs_result));
    return nullptr;
  }
  LOG("Loaded library");
  Dart_ExitIsolate();
  return &isolates_.emplace_back(IsolateHandle{isolate, library});
}

void DartEmbedder::Shutdown() {
  for (const auto& isolate : isolates_) {
    USE(isolate.library_);
    Dart_KillIsolate(isolate.isolate_);
  }
}
}  // namespace dart::embedder::simple
