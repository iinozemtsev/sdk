// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:isolate";
import "dart:async";
import "package:expect/async_helper.dart";
import "package:expect/expect.dart";

isomain1(replyPort) {
  RawReceivePort port = new RawReceivePort();
  port.handler = (v) {
    replyPort.send(v);
    if (v == 0) port.close();
  };
  replyPort.send(port.sendPort);
}

void main() {
  asyncStart();
  var completer = new Completer(); // Completed by first reply from isolate.
  RawReceivePort reply = new RawReceivePort(completer.complete);
  Isolate.spawn(isomain1, reply.sendPort).then((Isolate isolate) {
    List result = [];
    completer.future.then((echoPort) {
      reply.handler = (v) {
        result.add(v);
        if (v == 0) {
          Expect.listEquals([4, 3, 2, 1, 0], result);
          reply.close();
          asyncEnd();
        }
      };
      echoPort.send(4);
      echoPort.send(3);
      Capability resume = isolate.pause();
      var pingPort = new RawReceivePort();
      pingPort.handler = (_) {
        Expect.isTrue(result.length <= 2);
        echoPort.send(0);
        isolate.resume(resume);
        pingPort.close();
      };
      isolate.ping(pingPort.sendPort, priority: Isolate.beforeNextEvent);
      echoPort.send(2);
      echoPort.send(1);
    });
  });
}
