// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'common.dart';

@pragma('dyn-module:entry-point')
Object? entrypoint() => const A();

// TODO(sigmund): remove or reconcile. W/O a main dart2bytecode produces
// a compile-time error.
main() {}
