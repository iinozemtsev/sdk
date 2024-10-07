// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../linter_lint_codes.dart';

const _desc = r'Inline list item declarations where possible.';

class PreferInlinedAdds extends LintRule {
  PreferInlinedAdds()
      : super(
          name: LintNames.prefer_inlined_adds,
          description: _desc,
        );

  @override
  List<LintCode> get lintCodes => [
        LinterLintCode.prefer_inlined_adds_multiple,
        LinterLintCode.prefer_inlined_adds_single
      ];

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation invocation) {
    var addAll = invocation.methodName.name == 'addAll';
    if ((invocation.methodName.name != 'add' && !addAll) ||
        !invocation.isCascaded ||
        invocation.argumentList.arguments.length != 1) {
      return;
    }

    var cascade = invocation.thisOrAncestorOfType<CascadeExpression>();
    var sections = cascade?.cascadeSections;
    var target = cascade?.target;
    if (target is! ListLiteral ||
        (sections != null && sections.first != invocation)) {
      // TODO(pq): consider extending to handle set literals.
      return;
    }

    if (addAll && invocation.argumentList.arguments.first is! ListLiteral) {
      // Handled by: prefer_spread_collections
      return;
    }

    rule.reportLint(invocation.methodName,
        errorCode: addAll
            ? LinterLintCode.prefer_inlined_adds_multiple
            : LinterLintCode.prefer_inlined_adds_single);
  }
}
