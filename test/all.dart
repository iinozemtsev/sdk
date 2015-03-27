// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/io.dart';
import 'package:unittest/unittest.dart';

import 'config_test.dart' as config_test;
import 'formatter_test.dart' as formatter_test;
import 'integration_test.dart' as integration_test;
import 'io_test.dart' as io_test;
import 'linter_test.dart' as linter_test;
import 'mocks.dart';
import 'project_test.dart' as project_test;
import 'pub_test.dart' as pub_test;

main() {
  // Tidy up the unittest output.
  filterStacks = true;
  formatStacks = true;

  // useCompactVMConfiguration();
  // useTimingConfig();

  // Redirect output.
  outSink = new MockIOSink();

  linter_test.main();
  pub_test.main();
  io_test.main();
  formatter_test.main();
  config_test.main();
  project_test.main();
  integration_test.main();
}

void useTimingConfig() {
  unittestConfiguration = new TimingTestConfig();
}

class TimingTestConfig extends SimpleConfiguration {
  final stopwatch = new Stopwatch();

  @override
  void onDone(bool success) {
    stopwatch.stop();
    super.onDone(success);
    print('Total time = ${stopwatch.elapsedMilliseconds / 1000} seconds.');
  }

  @override
  void onStart() => stopwatch.start();
}
