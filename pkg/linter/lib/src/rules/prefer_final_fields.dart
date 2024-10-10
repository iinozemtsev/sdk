// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';
import '../extensions.dart';

const _desc = r'Private field could be `final`.';

class PreferFinalFields extends LintRule {
  PreferFinalFields()
      : super(
          name: LintNames.prefer_final_fields,
          description: _desc,
        );

  @override
  LintCode get lintCode => LinterLintCode.prefer_final_fields;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addCompilationUnit(this, visitor);
  }
}

class _DeclarationsCollector extends RecursiveAstVisitor<void> {
  final fields = <FieldElement, VariableDeclaration>{};

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    if (node.isInvalidExtensionTypeField) return;
    if (node.parent is EnumDeclaration) return;
    if (node.fields.isFinal || node.fields.isConst) {
      return;
    }

    for (var variable in node.fields.variables) {
      var element = variable.declaredElement;
      if (element is FieldElement &&
          element.isPrivate &&
          !element.overridesField) {
        fields[element] = variable;
      }
    }
  }
}

class _FieldMutationFinder extends RecursiveAstVisitor<void> {
  /// The collection of fields declared in this library.
  ///
  /// This visitor removes a field when it finds that it is assigned anywhere.
  final Map<FieldElement, VariableDeclaration> _fields;

  _FieldMutationFinder(this._fields);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _addMutatedFieldElement(node);
    super.visitAssignmentExpression(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _addMutatedFieldElement(node);
    super.visitPostfixExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    var operator = node.operator;
    if (operator.type == TokenType.MINUS_MINUS ||
        operator.type == TokenType.PLUS_PLUS) {
      _addMutatedFieldElement(node);
    }
    super.visitPrefixExpression(node);
  }

  void _addMutatedFieldElement(CompoundAssignmentExpression assignment) {
    var element = assignment.writeElement?.canonicalElement;
    if (element is FieldElement) {
      _fields.remove(element);
    }
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  final LinterContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    var declarationsCollector = _DeclarationsCollector();
    node.accept(declarationsCollector);
    var fields = declarationsCollector.fields;

    var fieldMutationFinder = _FieldMutationFinder(fields);
    for (var unit in context.allUnits) {
      unit.unit.accept(fieldMutationFinder);
    }

    for (var MapEntry(key: field, value: variable) in fields.entries) {
      // TODO(srawlins): We could look at the constructors once and store a set
      // of which fields are initialized by any, and a set of which fields are
      // initialized by all. This would conceivably improve performance.
      var classDeclaration = variable.parent?.parent?.parent;
      var constructors = classDeclaration is ClassDeclaration
          ? classDeclaration.members.whereType<ConstructorDeclaration>()
          : <ConstructorDeclaration>[];

      var isSetInAnyConstructor = constructors
          .any((constructor) => field.isSetInConstructor(constructor));

      if (isSetInAnyConstructor) {
        var isSetInEveryConstructor = constructors
            .every((constructor) => field.isSetInConstructor(constructor));

        if (isSetInEveryConstructor) {
          rule.reportLint(variable, arguments: [variable.name.lexeme]);
        }
      } else if (field.hasInitializer) {
        rule.reportLint(variable, arguments: [variable.name.lexeme]);
      }
    }
  }
}

extension on VariableElement {
  bool get overridesField {
    var enclosingElement = enclosingElement3;
    if (enclosingElement is! InterfaceElement) return false;

    var library = this.library;
    if (library == null) return false;

    return enclosingElement.thisType
            .lookUpSetter2(name, inherited: true, library) !=
        null;
  }

  bool isSetInConstructor(ConstructorDeclaration constructor) =>
      constructor.initializers.any(isSetInInitializer) ||
      constructor.parameters.parameters.any(isSetInParameter);

  /// Whether `this` is initialized in [initializer].
  bool isSetInInitializer(ConstructorInitializer initializer) =>
      initializer is ConstructorFieldInitializer &&
      initializer.fieldName.canonicalElement == this;

  /// Whether `this` is initialized with [parameter].
  bool isSetInParameter(FormalParameter parameter) {
    var formalField = parameter.declaredElement;
    return formalField is FieldFormalParameterElement &&
        formalField.field == this;
  }
}
