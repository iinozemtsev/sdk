// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Target architecture for cross compilation.
enum TargetArchitecture {
  x64('x64'),
  arm64('arm64');

  final String name;
  const TargetArchitecture(this.name);

  static final Iterable<String> names = values.map((v) => v.name);

  static TargetArchitecture? fromString(String s) {
    for (final value in values) {
      if (value.name == s) return value;
    }
    return null;
  }

  @override
  String toString() => name;
}
