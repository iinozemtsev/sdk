import 'dart:isolate';

void helloWorld() {
  print('Hello, world! I am Dart');
}

var hwCalled = false;
String gimmeString() {
  hwCalled = true;
  return  'Hello, world! I am string from Dart';
}

String greet(String name) => 'Hello, $name! Btw, hwCalled: $hwCalled';

void main(List<String> args, [SendPort? sendPort]) {
  if (sendPort != null) {
    sendPort.send('Hello, swift!');
  }
}
