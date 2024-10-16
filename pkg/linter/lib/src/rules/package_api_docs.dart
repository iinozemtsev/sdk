// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

import '../analyzer.dart';

const _desc = r'Provide doc comments for all public APIs.';

class PackageApiDocs extends LintRule {
  PackageApiDocs()
      : super(
          name: LintNames.package_api_docs,
          description: _desc,
          state: State.deprecated(since: Version(3, 7, 0)),
        );

  @override
  LintCode get lintCode => LinterLintCode.removed_lint;
}
