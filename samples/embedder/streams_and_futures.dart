import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

void main() => throw 'Unimplemented';

/// Regular Dart function returning a Future.
Future<int> produceFuture(int input, int millis) async {
  await Future.delayed(Duration(milliseconds: millis));
  return input * 2;
}

/// Call [produceFuture] from the native code using ports.
@pragma('vm:entry-point', 'call')
void produceFuturePorts(int input, int millis, SendPort port) async {
  port.send(await produceFuture(input, millis));
}

/// Call [produceFuture] from the native code using native callbacks.
@pragma('vm:entry-point', 'call')
void produceFutureFfi(int input, int millis, int fnPointer, int ctx) async {
  final callback = Pointer<
    NativeFunction<Void Function(IntPtr, Pointer<Opaque>)>
  >.fromAddress(fnPointer);
  final context = Pointer<Opaque>.fromAddress(ctx);
  final result = await produceFuture(input, millis);
  callback.asFunction<void Function(int, Pointer<Opaque>)>().call(
    result,
    context,
  );
}

/// Regular Dart function returning a stream.
Stream<int> produceStreamDiy(int count, int delayMillis) {
  final delay = Duration(milliseconds: delayMillis);

  final sc = StreamController<int>();
  () async {
    for (var i = 0; i < count; i++) {
      await Future.delayed(delay);
      sc.add(i);
    }
    sc.close();
  }();
  return sc.stream;
}

Stream<int> produceStream(int count, int delayMillis) async* {
  final delay = Duration(milliseconds: delayMillis);
  for (var i = 0; i < count; i++) {
    print("Dart: yielding $i");
    await Future.delayed(delay);
    yield i;
  }
}

final class NativeIntSink extends Struct {
  external Pointer<NativeFunction<Void Function(Pointer<Opaque>, Int64)>> add;
  external Pointer<NativeFunction<Void Function(Pointer<Opaque>)>> close;
  external Pointer<Opaque> context;
}

@pragma('vm:entry-point', 'call')
void produceStreamFfi(int count, int delayMillis, int sinkPtr) async {
  final sink = Pointer<NativeIntSink>.fromAddress(sinkPtr);
  final stream = produceStreamDiy(count, delayMillis);
  await for (var value in stream) {
    sink.ref.add.asFunction<void Function(Pointer<Opaque>, int)>()(
      sink.ref.context,
      value,
    );
  }
  sink.ref.close.asFunction<void Function(Pointer<Opaque>)>()(sink.ref.context);
}

/// Wrapper for calling [produceSomething] from the native code.
@pragma('vm:entry-point', 'call')
void produceStreamPorts(
  int count,
  int delayMillis,
  SendPort output,
  SendPort closeSignal,
) async {
  await for (var value in produceStream(count, delayMillis)) {
    output.send(value);
  }
  closeSignal.send(true);
}

/// Regular Dart function consuming a Future.
Future<int> consumeFutureImpl(Future<int> value) async => (await value) * 2;

/// Wrapper for calling [consumeFutureImpl] from the native code.
@pragma('vm:entry-point', 'call')
void consumeFuture(SendPort portPort, SendPort returnPort) async {
  final receiveFuture = ReceivePort();
  portPort.send(receiveFuture.sendPort);
  returnPort.send(
    await consumeFutureImpl(receiveFuture.first.then<int>((v) => v)),
  );
}

/// Regular Dart function consuming a Stream.
Future<int> consumeStreamImpl(Stream<int> values) async {
  var sum = 0;
  await for (var value in values) {
    sum += value;
  }
  return sum;
}

/// Wrapper for calling [consumeStreamImpl] from the native code.
@pragma('vm:entry-point', 'call')
void consumeStream(SendPort portPort, SendPort returnPort) async {
  final receiveStream = ReceivePort();
  final receiveDone = ReceivePort();
  portPort.send(receiveStream.sendPort);
  portPort.send(receiveDone.sendPort);
  receiveDone.single.then((_) => receiveStream.close()).ignore();
  returnPort.send(await consumeStreamImpl(receiveStream.cast<int>()));
}
