// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'common/service_test_common.dart';
import 'common/test_helper.dart';

// AUTOGENERATED START
//
// Update these constants by running:
//
// dart pkg/vm_service/test/update_line_numbers.dart <test.dart>
//
const LINE_A = 19;
// AUTOGENERATED END

const file = 'step_through_catch_test.dart';

void code() /* LINE_A */ {
  try {
    final value = 'world';
    throw 'Hello, $value';
  } catch (e, st) {
    print(e);
    print(st);
  }
  try {
    throw 'Hello, world';
  } catch (e, st) {
    print(e);
    print(st);
  }
}

final stops = <String>[];
const expected = <String>[
  '$file:$LINE_A:10', // on '(' of 'void code()'
  '$file:${LINE_A + 2}:17', // on '='
  '$file:${LINE_A + 3}:26', // after last ''' (i.e. before ';')
  '$file:${LINE_A + 5}:5', // on call to 'print'
  '$file:${LINE_A + 6}:5', // on call to 'print'
  '$file:${LINE_A + 9}:5', // on 'throw'
  '$file:${LINE_A + 11}:5', // on call to 'print'
  '$file:${LINE_A + 12}:5', // on call to 'print'
  '$file:${LINE_A + 14}:1', // on ending '}'
];

final tests = <IsolateTest>[
  hasPausedAtStart,
  setBreakpointAtLine(LINE_A),
  runStepThroughProgramRecordingStops(stops),
  checkRecordedStops(stops, expected),
];

void main([args = const <String>[]]) => runIsolateTests(
      args,
      tests,
      'step_through_catch_test.dart',
      testeeConcurrent: code,
      pauseOnStart: true,
      pauseOnExit: true,
    );
