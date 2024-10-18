import 'dart:async';
import 'dart:isolate';

void helloWorld() {
  print('Hello, world! I am Dart');
}

var hwCalled = false;
String gimmeString() {
  hwCalled = true;
  return 'Hello, world! I am string from Dart';
}

var _tickCount = 0;
Timer? _tickTimer;

void startTicker() {
  if (_tickTimer != null) {
    _tickTimer = Timer.periodic(const Duration(milliseconds: 1), (_) {
      _tickCount++;
    });
  }
}

void stopTicker() {
  _tickTimer?.cancel();
}

int getTicks() => _tickCount;

String greet(String name) => 'Hello, $name! Btw, hwCalled: $hwCalled';

void main() {}
