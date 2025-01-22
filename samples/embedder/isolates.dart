import 'dart:isolate';

void main() {
  throw 'Unimplemented';
}

final useIsolates = false;
@pragma('vm:entry-point', 'call')
void compute(int delayMillis, int count, SendPort port) async {
  print('Compute request received');
  final delay = Duration(milliseconds: delayMillis);
  final computations = await Future.wait(
    List.generate(
      count,
      (i) => useIsolates ? Isolate.run(() => computation(delay, i)) : computation(delay, i),
    ),
  );
  final result = computations.join('\n');
  port.send(result);
}

Future<String> computation(Duration delay, int i) async {
  print('Computation #${i + 1} started...');
  await Future.delayed(delay);
  return 'computation #${i + 1} done';
}
