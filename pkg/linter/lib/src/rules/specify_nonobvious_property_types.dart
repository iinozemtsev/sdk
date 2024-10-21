// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';
import '../util/obvious_types.dart';

const _desc = r'Specify non-obvious type annotations for local variables.';

class SpecifyNonObviousPropertyTypes extends LintRule {
  SpecifyNonObviousPropertyTypes()
      : super(
          name: 'specify_nonobvious_property_types',
          description: _desc,
          state: State.experimental(),
        );

  @override
  List<String> get incompatibleRules => const ['omit_local_variable_types'];

  @override
  LintCode get lintCode => LinterLintCode.specify_nonobvious_property_types;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addFieldDeclaration(this, visitor);
    registry.addTopLevelVariableDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitFieldDeclaration(FieldDeclaration node) =>
      _visitVariableDeclarationList(node.fields,
          isInstanceVariable: !node.isStatic);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) =>
      _visitVariableDeclarationList(node.variables, isInstanceVariable: false);

  void _visitVariableDeclarationList(VariableDeclarationList node,
      {required bool isInstanceVariable}) {
    var staticType = node.type?.type;
    if (staticType != null && !staticType.isDartCoreNull) {
      return;
    }
    bool aDeclaredTypeIsNeeded = false;
    var variablesThatNeedAType = <VariableDeclaration>[];
    for (var child in node.variables) {
      var initializer = child.initializer;
      if (isInstanceVariable) {
        // Ignore this variable if the type comes from override inference.
        bool ignoreThisVariable = false;
        AstNode? owningDeclaration = node;
        while (owningDeclaration != null) {
          InterfaceElement? owningElement = switch (owningDeclaration) {
            ClassDeclaration(:var declaredElement) => declaredElement,
            MixinDeclaration(:var declaredElement) => declaredElement,
            EnumDeclaration(:var declaredElement) => declaredElement,
            ExtensionTypeDeclaration(:var declaredElement) => declaredElement,
            _ => null,
          };
          if (owningElement != null) {
            var variableName = child.name.lexeme;
            for (var superInterface in owningElement.allSupertypes) {
              if (superInterface.getGetter(variableName) != null) {
                ignoreThisVariable = true;
              }
              if (superInterface.getSetter(variableName) != null) {
                ignoreThisVariable = true;
              }
            }
          }
          owningDeclaration = owningDeclaration.parent;
        }
        if (ignoreThisVariable) continue;
      }
      if (initializer == null) {
        aDeclaredTypeIsNeeded = true;
        variablesThatNeedAType.add(child);
      } else {
        if (!initializer.hasObviousType) {
          aDeclaredTypeIsNeeded = true;
          variablesThatNeedAType.add(child);
        }
      }
    }
    if (aDeclaredTypeIsNeeded) {
      if (node.variables.length == 1) {
        rule.reportLint(node);
      } else {
        // Multiple variables, report each of them separately. No fix.
        variablesThatNeedAType.forEach(rule.reportLint);
      }
    }
  }
}
