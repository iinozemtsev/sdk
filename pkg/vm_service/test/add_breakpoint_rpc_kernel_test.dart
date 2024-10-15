// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

import 'common/service_test_common.dart';
import 'common/test_helper.dart';

// AUTOGENERATED START
//
// Update these constants by running:
//
// dart pkg/vm_service/test/update_line_numbers.dart <test.dart>
//
const LINE_A = 30;
// AUTOGENERATED END

int value = 0;

int incValue(int amount) {
  value += amount;
  return amount;
}

Future<void> testMain() async {
  incValue(incValue(1)); // LINE_A.
}

final tests = <IsolateTest>[
  hasPausedAtStart,

  (VmService service, IsolateRef isolateRef) async {
    final isolateId = isolateRef.id!;
    final isolate = await service.getIsolate(isolateId);
    final rootLib =
        await service.getObject(isolateId, isolate.rootLib!.id!) as Library;
    final rootLibId = rootLib.id!;
    final scriptId = rootLib.scripts![0].id!;

    final bpt1 = await service.addBreakpoint(isolateId, scriptId, LINE_A);
    expect(bpt1.breakpointNumber, 1);
    expect(bpt1.resolved, true);
    expect(await bpt1.location!.line!, LINE_A);
    expect(await bpt1.location!.column, 12);

    // Breakpoint with specific column.
    final bpt2 =
        await service.addBreakpoint(isolateId, scriptId, LINE_A, column: 3);
    expect(bpt2.breakpointNumber, 2);
    expect(bpt2.resolved, true);
    expect(await bpt2.location!.line!, LINE_A);
    expect(await bpt2.location!.column!, 3);

    await service.resume(isolateId);
    await hasStoppedAtBreakpoint(service, isolate);
    // The first breakpoint hits before value is modified.
    InstanceRef result =
        await service.evaluate(isolateId, rootLibId, 'value') as InstanceRef;
    expect(result.valueAsString, '0');

    await service.resume(isolateId);
    await hasStoppedAtBreakpoint(service, isolate);
    // The second breakpoint hits after value has been modified once.
    result =
        await service.evaluate(isolateId, rootLibId, 'value') as InstanceRef;
    expect(result.valueAsString, '1');

    // Remove the breakpoints.
    expect(
      (await service.removeBreakpoint(isolateId, bpt1.id!)).type,
      'Success',
    );
    expect(
      (await service.removeBreakpoint(isolateId, bpt2.id!)).type,
      'Success',
    );
  },

  // Test resolution of column breakpoints.
  (VmService service, IsolateRef isolateRef) async {
    final isolateId = isolateRef.id!;
    final isolate = await service.getIsolate(isolateId);
    final rootLibId = isolate.rootLib!.id!;
    final rootLib = await service.getObject(isolateId, rootLibId) as Library;

    final scriptId = rootLib.scripts![0].id!;
    final script = await service.getObject(isolateId, scriptId) as Script;

    // Try all valid column arguments.
    for (int col = 1; col <= 36; col++) {
      final bpt =
          await service.addBreakpoint(isolateId, scriptId, LINE_A, column: col);
      expect(bpt.resolved, isTrue);
      final int resolvedLine = script.getLineNumberFromTokenPos(
        bpt.location!.tokenPos!,
      )!;
      final int resolvedCol = script.getColumnNumberFromTokenPos(
        bpt.location!.tokenPos!,
      )!;
      print('$LINE_A:$col -> $resolvedLine:$resolvedCol');
      if (col < 12) {
        // The second 'incValue' begins at column 12.
        expect(resolvedLine, LINE_A);
        expect(bpt.location!.line, LINE_A);
        expect(resolvedCol, 3);
        expect(bpt.location!.column, 3);
      } else {
        // The newline character at the end of LINE_A is at column 36.
        expect(resolvedLine, LINE_A);
        expect(bpt.location!.line, LINE_A);
        expect(resolvedCol, 12);
        expect(bpt.location!.column, 12);
      }
      expect(
        (await service.removeBreakpoint(isolateId, bpt.id!)).type,
        'Success',
      );
    }

    // Ensure that an error is thrown when 0 is passed as the column argument.
    try {
      await service.addBreakpoint(isolateId, scriptId, LINE_A, column: 0);
      fail('Expected to catch an RPC error');
    } on RPCError catch (e) {
      expect(e.code, RPCErrorKind.kInvalidParams.code);
      expect(e.details, "addBreakpoint: invalid 'column' parameter: 0");
    }

    // Ensure that an error is thrown when a number greater than the number of
    // columns on the specified line is passed as the column argument.
    try {
      await service.addBreakpoint(isolateId, scriptId, LINE_A, column: 37);
      fail('Expected to catch an RPC error');
    } on RPCError catch (e) {
      expect(e.code, RPCErrorKind.kCannotAddBreakpoint.code);
      expect(
        e.details,
        'addBreakpoint: Cannot add breakpoint at line $LINE_A. Error occurred '
        'when resolving breakpoint location: No debuggable code where '
        'breakpoint was requested.',
      );
    }
  },
];

Future<void> main(args) => runIsolateTests(
      args,
      tests,
      'add_breakpoint_rpc_kernel_test.dart',
      testeeConcurrent: testMain,
      pauseOnStart: true,
    );
