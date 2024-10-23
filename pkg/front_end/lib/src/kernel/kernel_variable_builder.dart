// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library fasta.kernel_variable_builder;

import 'package:kernel/ast.dart' show VariableDeclaration;

import '../builder/builder.dart';
import '../builder/variable_builder.dart';

class VariableBuilderImpl extends BuilderImpl implements VariableBuilder {
  @override
  final Uri fileUri;

  @override
  final VariableDeclaration variable;

  VariableBuilderImpl(this.variable, this.fileUri);

  @override
  // Coverage-ignore(suite): Not run.
  Builder? get parent => null;

  @override
  int get fileOffset => variable.fileOffset;

  @override
  bool get isLocal => true;

  @override
  bool get isConst => variable.isConst;

  @override
  bool get isAssignable => variable.isAssignable;

  @override
  // Coverage-ignore(suite): Not run.
  String get fullNameForErrors => variable.name ?? "<unnamed>";

  @override
  String toString() => 'VariableBuilderImpl($fullNameForErrors)';
}
