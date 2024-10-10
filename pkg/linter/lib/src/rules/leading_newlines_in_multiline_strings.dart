// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Start multiline strings with a newline.';

class LeadingNewlinesInMultilineStrings extends LintRule {
  LeadingNewlinesInMultilineStrings()
      : super(
          name: LintNames.leading_newlines_in_multiline_strings,
          description: _desc,
        );

  @override
  LintCode get lintCode => LinterLintCode.leading_newlines_in_multiline_strings;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addCompilationUnit(this, visitor);
    registry.addSimpleStringLiteral(this, visitor);
    registry.addStringInterpolation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  LineInfo? lineInfo;

  _Visitor(this.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    lineInfo = node.lineInfo;
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _visitSingleStringLiteral(node, node.literal.lexeme);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    _visitSingleStringLiteral(
        node, (node.elements.first as InterpolationString).contents.lexeme);
  }

  void _visitSingleStringLiteral(SingleStringLiteral node, String lexeme) {
    var nodeLineInfo = lineInfo;
    if (nodeLineInfo == null) {
      return;
    }
    if (node.isMultiline &&
        nodeLineInfo.getLocation(node.offset).lineNumber !=
            nodeLineInfo.getLocation(node.end).lineNumber) {
      bool startWithNewLine(int index) =>
          lexeme.startsWith('\n', index) || lexeme.startsWith('\r', index);
      if (!startWithNewLine(node.isRaw ? 4 : 3)) {
        rule.reportLint(node);
      }
    }
  }
}
