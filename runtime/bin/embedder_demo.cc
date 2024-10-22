#include <condition_variable>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <functional>
#include <iostream>
#include <mutex>
#include <queue>
#include <string_view>
#include <thread>
#include <unordered_map>
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

struct ThreadState {
  std::unordered_map<Dart_Isolate, std::mutex> mutexes;
  std::queue<Dart_Isolate> notifications;

  std::mutex notifications_mutex;
  std::condition_variable can_pop;
  std::atomic<bool> stopped;

  void NotifyMessage(Dart_Isolate isolate) {
    //    std::cout << "Got message for isolate" << std::endl;
    std::unique_lock notifications_lock(notifications_mutex);
    notifications.push(isolate);
    can_pop.notify_one();
  }

  void Stop() {
    std::unique_lock notifications_lock(notifications_mutex);
    stopped = true;
    can_pop.notify_one();
  }
};

template <typename T>
T WithIsolate(ThreadState& ts, Dart_Isolate isolate, std::function<T()> body) {
  std::unique_lock lock(ts.mutexes[isolate]);
  return body();
}

void MessageNotifyCallback(Dart_Isolate isolate) {
  auto* thread_state = static_cast<ThreadState*>(Dart_IsolateData(isolate));
  // std::cout << "MessageNotifyCallback" << std::endl;
  thread_state->NotifyMessage(isolate);
}

void EventLoop(ThreadState* state) {
  std::cout << "Event loop started" << std::endl;
  while (!state->stopped) {
    std::unique_lock notifications_lock(state->notifications_mutex);
    // std::cout << "Waiting for notifications..." << std::endl;
    state->can_pop.wait(notifications_lock, [=] {
      return !state->notifications.empty() || state->stopped;
    });
    if (state->stopped) {
      return;
    }
    // std::cout << "Handling notification..." << std::endl;
    Dart_Isolate isolate = state->notifications.front();
    state->notifications.pop();

    std::unique_lock isolate_lock(state->mutexes[isolate]);
    Dart_EnterIsolate(isolate);
    Dart_EnterScope();
    Dart_Handle handle_result = Dart_HandleMessage();
    if (Dart_IsError(handle_result)) {
      // TODO(iinozemtsev): add support for unhandled exceptions.
      std::cout << "Error handling message: " << Dart_GetError(handle_result)
                << std::endl;
    }
    Dart_ExitScope();
    Dart_ExitIsolate();
  }
  std::cout << "Event loop finished" << std::endl;
}

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
  ThreadState thread_state;
  std::thread event_loop_thread(EventLoop, &thread_state);

  if (!embedder.Init(&error)) {
    std::cout << "Failed to run embedder: " << error << std::endl;
    return 1;
  }

  dart::embedder::simple::IsolateHandle* isolate =
      embedder.IsolateGroupFromKernel(data, &error, &MessageNotifyCallback,
                                      &thread_state);
  if (isolate == nullptr) {
    std::cout << "Failed to run embedder: " << error << std::endl;
    return 1;
  }

  GeneratedForSendString send_string(isolate);
  std::cout << "Current ticks: "
            << WithIsolate<uint64_t>(
                   thread_state, isolate->isolate_,
                   [&]() { return send_string.GetTicks().value_or_die(); })
            << std::endl;

  WithIsolate<void>(thread_state, isolate->isolate_,
                    [&]() { return send_string.StartTimer().check_ok(); });

  std::cout << "Started timer" << std::endl;
  std::this_thread::sleep_for(std::chrono::milliseconds(100));
  WithIsolate<void>(thread_state, isolate->isolate_,
                    [&]() { return send_string.StopTimer().check_ok(); });

  std::this_thread::sleep_for(std::chrono::milliseconds(1000));
  std::cout << "Ticks: "
            << WithIsolate<uint64_t>(
                   thread_state, isolate->isolate_,
                   [&]() { return send_string.GetTicks().value_or_die(); })
            << std::endl;
  thread_state.Stop();
  event_loop_thread.join();

  // TODO: use Dart_SetMessageNotifyCallback
  //return Greetings(send_string);
}
