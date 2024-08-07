// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:_internal" show patch;
import "dart:ffi" show Handle, Void, Native;
import "dart:nativewrappers" show NativeFieldWrapperClass1;

@patch
@pragma("vm:entry-point")
abstract interface class Mutex {
  @patch
  factory Mutex._() => _MutexImpl();
}

@pragma("vm:entry-point")
base class _MutexImpl extends NativeFieldWrapperClass1 implements Mutex {
  _MutexImpl() {
    _initialize();
  }

  @Native<Void Function(Handle)>(symbol: "Mutex_Initialize")
  external void _initialize();

  @patch
  @Native<Void Function(Handle)>(symbol: "Mutex_Lock")
  external void _lock();

  @patch
  @Native<Void Function(Handle)>(symbol: "Mutex_Unlock")
  external void _unlock();

  R runLocked<R>(R Function() action) {
    _lock();
    try {
      return action();
    } finally {
      _unlock();
    }
  }
}

@patch
@pragma("vm:entry-point")
abstract interface class ConditionVariable {
  @patch
  factory ConditionVariable._() => _ConditionVariableImpl();
}

@pragma('vm:entry-point')
base class _ConditionVariableImpl extends NativeFieldWrapperClass1
    implements ConditionVariable {
  _ConditionVariableImpl() {
    _initialize();
  }

  @Native<Void Function(Handle)>(symbol: "ConditionVariable_Initialize")
  external void _initialize();

  @patch
  @Native<Void Function(Handle, Handle)>(symbol: "ConditionVariable_Wait")
  external void wait(Mutex mutex);

  @patch
  @Native<Void Function(Handle)>(symbol: "ConditionVariable_Notify")
  external void notify();
}
