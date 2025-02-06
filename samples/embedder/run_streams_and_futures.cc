#include <future>
#include <iostream>
#include <mutex>
#include <thread>
#include "helpers.h"
#include "include/dart_api.h"
#include "include/dart_engine.h"
#include "include/dart_native_api.h"

// Port-related machinery. Should be part of dart_engine.h eventually.

typedef void (*DartEngine_PortMessageHandler)(Dart_Port dest_port_id,
                                              Dart_CObject* message,
                                              void* context);

struct DartEngine_PortHandler {
  DartEngine_PortMessageHandler handler;
  void* context;
};

Dart_Port DartEngine_NewNativePort(const char* name,
                                   DartEngine_PortHandler handler);

// Dart_engine impl.
class PortHandlers {
 public:
  void HandleMessage(Dart_Port dest_port_id, Dart_CObject* message) {
    DartEngine_PortHandler handler;
    {
      std::unique_lock handlers_lock(handlers_mutex_);
      handler = handlers_[dest_port_id];
    }
    if (handler.handler == nullptr) {
      std::cerr << "No handler for port " << dest_port_id << std::endl;
      std::exit(1);
    }
    handler.handler(dest_port_id, message, handler.context);
  }

  void AddHandler(Dart_Port port_id, DartEngine_PortHandler handler) {
    std::unique_lock handlers_lock(handlers_mutex_);
    handlers_[port_id] = handler;
  }

  void RemoveHandler(Dart_Port port_id) {
    std::unique_lock handlers_lock(handlers_mutex_);
    handlers_.erase(port_id);
  }

 private:
  // todo: replace with Dart Mutex.
  std::mutex handlers_mutex_;
  std::unordered_map<Dart_Port, DartEngine_PortHandler> handlers_;
};

PortHandlers* handlers = new PortHandlers();

/// Global port handler.
void HandlePortMessage(Dart_Port dest_port_id, Dart_CObject* message) {
  handlers->HandleMessage(dest_port_id, message);
}

Dart_Port DartEngine_NewNativePort(const char* name,
                                   DartEngine_PortHandler handler,
                                   intptr_t max_concurrency) {
  Dart_Port result =
      Dart_NewConcurrentNativePort(name, HandlePortMessage, max_concurrency);
  handlers->AddHandler(result, handler);
  return result;
}

bool DartEngine_CloseNativePort(Dart_Port native_port_id) {
  handlers->RemoveHandler(native_port_id);
  return Dart_CloseNativePort(native_port_id);
}

// Snapshot-specific stuff

/// assumes the context is an int promise.
void IntToPromiseHandler(Dart_Port dest_port_id,
                         Dart_CObject* message,
                         void* context) {
  auto promise = reinterpret_cast<std::promise<int64_t>*>(context);
  if (message->type == Dart_CObject_kInt32) {
    promise->set_value(message->value.as_int32);
  } else if (message->type == Dart_CObject_kInt64) {
    promise->set_value(message->value.as_int64);
  } else {
    std::cerr << "Expected int32 or int64, got " << message->type << std::endl;
    std::exit(1);
  }

  delete promise;
}

void DartPortToPromiseHandler(Dart_Port dest_port_id,
                              Dart_CObject* message,
                              void* context) {
  auto promise = reinterpret_cast<std::promise<int64_t>*>(context);
  if (message->type == Dart_CObject_kSendPort) {
    promise->set_value(message->value.as_send_port.id);
  } else {
    std::cerr << "Expected SendPort, got " << message->type << std::endl;
    std::exit(1);
  }

  delete promise;
}

// TODO: how to close port?

std::future<int64_t> ProduceFuturePorts(Dart_Isolate isolate,
                                        int64_t input,
                                        int64_t millis) {
  // Create a promise on heap.
  auto promise = new std::promise<int64_t>();
  DartEngine_AcquireIsolate(isolate);
  Dart_EnterScope();

  Dart_Port port = DartEngine_NewNativePort("ProduceFuture",
                                            {IntToPromiseHandler, promise}, 1);

  std::initializer_list<Dart_Handle> args{
      Dart_NewInteger(input), Dart_NewInteger(millis), Dart_NewSendPort(port)};
  CheckError(Dart_Invoke(Dart_RootLibrary(),
                         Dart_NewStringFromCString("produceFuturePorts"), 3,
                         const_cast<Dart_Handle*>(args.begin())));
  Dart_ExitScope();
  DartEngine_ReleaseIsolate();
  return promise->get_future();
}

void ConsumeInt(intptr_t int_value, void* context) {
  reinterpret_cast<std::promise<intptr_t>*>(context)->set_value(int_value);
}

std::future<intptr_t> ProduceFutureCallbacks(Dart_Isolate isolate,
                                             int64_t input,
                                             int64_t millis) {
  // Create a promise on heap.
  auto promise = new std::promise<intptr_t>();
  DartEngine_AcquireIsolate(isolate);
  Dart_EnterScope();

  std::initializer_list<Dart_Handle> args{
      Dart_NewInteger(input), Dart_NewInteger(millis),
      Dart_NewInteger(reinterpret_cast<intptr_t>(&ConsumeInt)),
      Dart_NewInteger(reinterpret_cast<intptr_t>(promise))};
  CheckError(Dart_Invoke(Dart_RootLibrary(),
                         Dart_NewStringFromCString("produceFutureFfi"), 4,
                         const_cast<Dart_Handle*>(args.begin())));
  Dart_ExitScope();
  DartEngine_ReleaseIsolate();
  return promise->get_future();
}

struct ConsumeFutureResult {
  std::future<Dart_Port> input_port;
  std::future<int64_t> result;
};

ConsumeFutureResult ConsumeFuture(Dart_Isolate isolate) {
  // Promise for a SendPort from Dart.
  auto port_promise = new std::promise<Dart_Port>();
  auto result_promise = new std::promise<int64_t>();

  auto port_future = port_promise->get_future();
  auto result_future = result_promise->get_future();

  DartEngine_AcquireIsolate(isolate);
  Dart_EnterScope();

  Dart_Port port_port = DartEngine_NewNativePort(
      "ConsumeFuture.portPort", {DartPortToPromiseHandler, port_promise}, 1);
  Dart_Port result_port = DartEngine_NewNativePort(
      "ConsumeFuture.resultPort", {IntToPromiseHandler, result_promise}, 1);

  std::initializer_list<Dart_Handle> args{Dart_NewSendPort(port_port),
                                          Dart_NewSendPort(result_port)};
  CheckError(Dart_Invoke(Dart_RootLibrary(),
                         Dart_NewStringFromCString("consumeFuture"), 2,
                         const_cast<Dart_Handle*>(args.begin())));
  Dart_ExitScope();
  DartEngine_ReleaseIsolate();
  return {std::move(port_future), std::move(result_future)};
}

void ScheduleDartMessage(Dart_Isolate isolate, void* context) {
  std::thread(DartEngine_HandleMessage, isolate).detach();
}

typedef void (*AddToStreamCallback)(void* ctx, int64_t value);
typedef void (*CloseStreamCallback)(void* ctx);

struct NativeIntSink {
  AddToStreamCallback add;
  CloseStreamCallback close;
  void* context;
};

void AddToStream(void* ctx, int64_t value);
void CloseStream(void* ctx);

// Helper class representing a stream returned from Dart.
class BlockingIntStream {
 public:
  BlockingIntStream()
      : native_sink_(NativeIntSink{AddToStream, CloseStream, this}) {};
  // Waits until the next element is available, or the stream is closed.
  // Returns true if there's a next element, false if the stream is closed.
  bool WaitNext() {
    if (IsClosed()) {
      return false;
    }

    std::unique_lock lock(mutex_);
    if (values_.empty()) {
      can_pop_.wait(lock);
    }
    return !values_.empty();
  }

  bool IsClosed() { return is_closed_; }
  // UB if IsClosed.
  int64_t Next() {
    std::unique_lock lock(mutex_);
    auto result = values_.front();
    values_.pop();
    return result;
  }

  void Add(int64_t value) {
    std::unique_lock lock(mutex_);
    values_.push(value);
    can_pop_.notify_one();
  }

  void Close() {
    is_closed_ = true;
    can_pop_.notify_all();
  }

  NativeIntSink* Sink() { return &native_sink_; }

 private:
  std::mutex mutex_;
  std::condition_variable can_pop_;
  std::queue<int64_t> values_;
  std::atomic<bool> is_closed_;
  NativeIntSink native_sink_;
};

void AddToStream(void* ctx, int64_t value) {
  reinterpret_cast<BlockingIntStream*>(ctx)->Add(value);
}

void CloseStream(void* ctx) {
  reinterpret_cast<BlockingIntStream*>(ctx)->Close();
}

std::unique_ptr<BlockingIntStream> ProduceStream(Dart_Isolate isolate,
                                                 int64_t count,
                                                 int64_t delay_millis) {
  auto stream = std::make_unique<BlockingIntStream>();
  DartEngine_AcquireIsolate(isolate);
  Dart_EnterScope();

  std::initializer_list<Dart_Handle> args{
      Dart_NewInteger(count),
      Dart_NewInteger(delay_millis),
      Dart_NewInteger(reinterpret_cast<intptr_t>(stream->Sink())),
  };
  CheckError(Dart_Invoke(Dart_RootLibrary(),
                         Dart_NewStringFromCString("produceStreamFfi"), 3,
                         const_cast<Dart_Handle*>(args.begin())));
  Dart_ExitScope();
  DartEngine_ReleaseIsolate();
  return stream;
}

int main(int argc, char** argv) {
  if (argc == 1) {
    std::cerr << "Must specify snapshot path";
    std::exit(1);
  }

  char* error = nullptr;
  DartEngine_SnapshotData snapshot_data = AutoSnapshotFromFile(argv[1], &error);
  CheckError(error, "reading snapshot");
  Dart_Isolate isolate = DartEngine_CreateIsolate(snapshot_data, &error);
  CheckError(error, "creating isolate");
  DartEngine_SetDefaultMessageScheduler({ScheduleDartMessage, nullptr});

  // ProduceFuture: native code awaits a future from Dart.
  std::future<int64_t> int_future = ProduceFuturePorts(isolate, 42, 10);
  std::cout << "ProduceFuture(42) returns: " << int_future.get() << std::endl;

  // ProduceFuture: native code awaits a future from Dart.
  std::future<intptr_t> int_future2 = ProduceFutureCallbacks(isolate, 256, 10);
  std::cout << "ProduceFuture(256) returns: " << int_future2.get() << std::endl;

  // ConsumeFuture: Dart code awaits a future from native.
  auto consume_future_result = ConsumeFuture(isolate);
  Dart_Port input_port = consume_future_result.input_port.get();
  Dart_CObject input;
  input.type = Dart_CObject_kInt64;
  input.value.as_int64 = 25;
  Dart_PostCObject(input_port, &input);
  std::cout << "ConsumeFuture(25) returns: "
            << consume_future_result.result.get() << std::endl;

  // ProduceStream: native code awaits a stream returned from Dart.
  auto stream = ProduceStream(isolate, 5, 100);
  std::cout << "ProduceStream call finished" << std::endl;
  while (stream->WaitNext()) {
    std::cout << "Dart emits: " << stream->Next() << std::endl;
  }
}
