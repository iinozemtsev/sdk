# Dart Easy Embedder

The `include/dart_easy_embedder_api.h` provides additional functions to embed
Dart VM and launch Kernel/AOT snapshots. It is not intended to be a
full-featured API, and should be used together with `dart_api.h`.

Comparing to `dart_api.h` it brings the following:

- Full initialization of Dart VM, including initializing core libraries.
- Easier handling of isolate messages
- Lock-guarded enter/exit isolate functions.

See examples in `samples/embedder` for usages of the API.

## Handling isolate messages

In `dart_api.h`, it is possible to specify
`Dart_MessageNotifyCallback` to receive notifications when isolate has
to handle event loop management. However, when using this API, use
still have to enter an isolate, enter scope, call `Dart_HandleMessage`
and then leave an isolate and a scope.

In `dart_api.h` there are two possible ways to handle asynchronous
isolate messages:

- `Dart_MessageNotifyCallback`: Users can pass a callback to get
  notifications about messages to handle, but handling messages still
  requires entering an isolate, entering a scope, calling
  `Dart_HandleMessage`, and then leaving a scope and an isolate.
- `Dart_RunLoop`: Users can invoke it on a separate thread, but then they won't be able to enter isolates from other threads.

As an easier (but not simpler!) alternative,
`dart_easy_embedder_api.h` allows to specify per isolate / default
message schedulers, which receive a single callback they should invoke
to handle an isolate message.

### Event Loop schedulers

You can create an event loop scheduler using `Dart_EE_CreateEventLoop`
function, set it as a default / per isolate message scheduler, and
then run `Dart_EE_RunEventLoop` in a separate thread. Other threads
can still enter isolates to call Dart functions.

See `samples/embedder/run_timer.cc` for sample usage. 

### Custom schedulers

Users can create their own `Dart_EE_MessageScheduler` struct and pass
it to `Dart_EE_SetMessageScheduler` /
`Dart_EE_SetDefaultMessageScheduler`. See
`samples/embedder/run_timer_async.cc` as an example.

## Entering / leaving isolates

Because easy embedder API uses its own message handling, it is
important to use `Dart_EE_EnterIsolate` / `Dart_EE_ExitIsolate`
instead of `Dart_EnterIsolate` /
`Dart_ExitIsolate`. `Dart_EE_EnterIsolate` blocks until an isolate can
be entered by trying to obtain an internal lock (which is released by
`Dart_EE_ExitIsolate`), while `Dart_EnterIsolate` crashes if some
other thread has entered the same isolate.
