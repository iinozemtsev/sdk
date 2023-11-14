// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unnecessary_parenthesis

import 'common/service_test_common.dart';
import 'common/test_helper.dart';

// AUTOGENERATED START
//
// Update these constants by running:
//
// dart pkg/vm_service/test/update_line_numbers.dart <test.dart>
//
const LINE_A = 28;
// AUTOGENERATED END

const file = 'next_through_implicit_call_test.dart';

int _fooCallNumber = 0;
void foo() {
  ++_fooCallNumber;
  print('Foo call #$_fooCallNumber!');
}

void code() {
  foo(); // LINE_A
  (foo)();
  final a = [foo];
  a[0]();
  (a[0])();
  final b = [
    [foo, foo],
  ];
  b[0][1]();
  (b[0][1])();
}

final stops = <String>[];
const expected = <String>[
  '$file:${LINE_A + 0}:3', // on 'foo'
  '$file:${LINE_A + 1}:8', // on '(' (in '()')
  '$file:${LINE_A + 2}:13', // on '['
  '$file:${LINE_A + 3}:4', // on '['
  '$file:${LINE_A + 3}:7', // on '('
  '$file:${LINE_A + 4}:5', // on '['
  '$file:${LINE_A + 4}:9', // on '(' (in '()')
  '$file:${LINE_A + 6}:5', // on '[' (inner one)
  '$file:${LINE_A + 5}:13', // on '[' (outer one)
  '$file:${LINE_A + 8}:4', // on first '['
  '$file:${LINE_A + 8}:7', // on second '['
  '$file:${LINE_A + 8}:10', // on '('
  '$file:${LINE_A + 9}:5', // on first '['
  '$file:${LINE_A + 9}:8', // on second '['
  '$file:${LINE_A + 9}:12', // on '(' (in '()')
  '$file:${LINE_A + 10}:1', // on ending '}'
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
      'next_through_implicit_call_test.dart',
      testeeConcurrent: code,
      pauseOnStart: true,
      pauseOnExit: true,
    );
