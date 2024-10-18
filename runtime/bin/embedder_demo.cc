#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string_view>
#include <thread>
#include "generated_for_send_string.h"
#include "include/dart_api.h"
#include "platform/assert.h"
#include "platform/utils.h"
#include "simple_embedder.h"

// struct SnapshotData {
//   uint64_t length;
//   char* bytes;
// };

using dart::embedder::simple::SnapshotData;
using dart::send_string::GeneratedForSendString;

SnapshotData read_file(std::string_view path, std::string_view name) {
  std::string path_string{path};
  std::ifstream source_file{path_string, std::ios::binary};

  ASSERT(source_file.good());
  source_file.seekg(0, source_file.end);
  uint64_t length = source_file.tellg();
  source_file.seekg(0, source_file.beg);

  char* bytes = static_cast<char*>(std::malloc(length));
  source_file.read(bytes, static_cast<long>(length));
  SnapshotData result{std::string(name), static_cast<const char*>(bytes),
                      length};
  return result;
}

int Greetings(GeneratedForSendString& send_string) {
  auto result = send_string.gimmeString();
  if (result.is_error) {
    std::cout << "Failed call Dart: " << result.error << std::endl;
    return 1;
  }

  std::cout << "Dart says: " << result.value << std::endl;

  std::cout << "Greeting...." << std::endl;
  auto greet_result = send_string.greet("Ivan");
  if (greet_result.is_error) {
    std::cout << "Failed to call Dart: " << greet_result.error << std::endl;
    return 1;
  }

  std::cout << "Dart says: " << greet_result.value << std::endl;
  return 0;
}

int main() {
  SnapshotData data =
      read_file("/Users/iinozemtsev/misc/send_string.dill", "send_string");
  dart::embedder::simple::DartEmbedder embedder;
  char* error;

  if (!embedder.Init(&error)) {
    std::cout << "Failed to run embedder: " << error << std::endl;
    return 1;
  }

  dart::embedder::simple::IsolateHandle* isolate =
      embedder.IsolateGroupFromKernel(data, &error);
  if (isolate == nullptr) {
    std::cout << "Failed to run embedder: " << error << std::endl;
    return 1;
  }

  GeneratedForSendString send_string(isolate);
  std::cout << "Current ticks: " << send_string.GetTicks().value_or_die() << std::endl;

  send_string.StartTimer().check_ok();
  std::cout << "Started timer" << std::endl;
  std::this_thread::sleep_for(std::chrono::milliseconds(100));
  std::cout << "Ticks after 100 ms: " << send_string.GetTicks().value_or_die() << std::endl;

  // TODO: use Dart_SetMessageNotifyCallback
  Dart_EnterIsolate(send_string.isolate_->isolate_);
  //return Greetings(send_string);
}


