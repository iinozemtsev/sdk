#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string_view>
#include "platform/assert.h"
#include "platform/utils.h"
#include "simple_embedder.h"

// struct SnapshotData {
//   uint64_t length;
//   char* bytes;
// };

using dart::embedder::simple::SnapshotData;

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

int main() {
  SnapshotData data =
      read_file("/Users/iinozemtsev/misc/send_string.dill", "send_string");
  // SnapshotData vm_platform = read_file(
  //     "/Users/iinozemtsev/work/dart-sdk-multiplat/sdk/xcodebuild/DebugARM64/"
  //     "dart-sdk/lib/_internal/vm_platform_strong.dill");
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

  dart::embedder::simple::GeneratedForSendString send_string(isolate);

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

  // if (!dart::embedder::simple::Run(data.bytes, data.size,
  //                                  // vm_platform.bytes, vm_platform.length,
  //                                  &error)) {
  //   std::cout << "Failed to run embedder: " << error << std::endl;
  // }

  return 0;
}
