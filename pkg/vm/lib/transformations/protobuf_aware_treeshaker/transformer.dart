// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:kernel/kernel.dart';
import 'package:kernel/target/targets.dart';
import 'package:kernel/core_types.dart';
import 'package:kernel/transformations/constants.dart' as constants;
import 'package:kernel/vm/constants_native_effects.dart' as vm_constants;
import 'package:meta/meta.dart';
import 'package:vm/transformations/type_flow/transformer.dart' as globalTypeFlow
    show transformComponent;
import 'package:vm/transformations/no_dynamic_invocations_annotator.dart'
    show Selector;

class TransformationInfo {
  final List<String> removedMessageFields = <String>[];
  final List<Class> removedMessageClasses = <Class>[];
}

TransformationInfo transformComponent(
    Component component, Map<String, String> environment, Target target,
    {@required bool collectInfo, @required bool enableAsserts}) {
  final coreTypes = new CoreTypes(component);
  component.computeCanonicalNames();

  // Evaluate constants to ensure @pragma("vm:entry-point") is seen by the
  // type-flow analysis.
  final vmConstants = new vm_constants.VmConstantsBackend(coreTypes);
  constants.transformComponent(component, vmConstants, environment, null,
      keepFields: true,
      evaluateAnnotations: true,
      enableAsserts: enableAsserts);

  TransformationInfo info = collectInfo ? TransformationInfo() : null;

  _treeshakeProtos(target, component, coreTypes, info);
  return info;
}

void _treeshakeProtos(Target target, Component component, CoreTypes coreTypes,
    TransformationInfo info) {
  globalTypeFlow.transformComponent(target, coreTypes, component);
  final collector = _removeUnusedProtoReferences(component, coreTypes, info);
  if (collector == null) {
    return;
  }
  globalTypeFlow.transformComponent(target, coreTypes, component);
  if (info != null) {
    for (Class gmSubclass in collector.gmSubclasses) {
      if (!gmSubclass.enclosingLibrary.classes.contains(gmSubclass)) {
        info.removedMessageClasses.add(gmSubclass);
      }
    }
  }
  // Remove metadata added by the typeflow analysis.
  component.metadata.clear();
}

InfoCollector _removeUnusedProtoReferences(
    Component component, CoreTypes coreTypes, TransformationInfo info) {
  final protobufUri = Uri.parse('package:protobuf/protobuf.dart');
  final protobufLibs =
      component.libraries.where((lib) => lib.importUri == protobufUri);
  if (protobufLibs.isEmpty) {
    return null;
  }
  final protobufLib = protobufLibs.single;

  final gmClass = protobufLib.classes
      .where((klass) => klass.name == 'GeneratedMessage')
      .single;
  final collector = InfoCollector(gmClass);

  final biClass =
      protobufLib.classes.where((klass) => klass.name == 'BuilderInfo').single;
  final addMethod =
      biClass.members.singleWhere((Member member) => member.name.name == 'add');

  component.accept(collector);

  _UnusedFieldMetadataPruner(
          biClass, addMethod, collector.dynamicSelectors, coreTypes, info)
      .removeMetadataForUnusedFields(
    collector.gmSubclasses,
    collector.gmSubclassesInvokedMethods,
    coreTypes,
    info,
  );

  return collector;
}

/// For protobuf fields which are not accessed, prune away its metadata.
class _UnusedFieldMetadataPruner extends TreeVisitor<void> {
  // All of those methods have the dart field name as second positional
  // parameter.
  // Method names are defined in:
  // https://github.com/dart-lang/protobuf/blob/master/protobuf/lib/src/protobuf/builder_info.dart
  // The code is generated by:
  // https://github.com/dart-lang/protobuf/blob/master/protoc_plugin/lib/protobuf_field.dart.
  static final fieldAddingMethods = Set<String>.from(const <String>[
    'a',
    'm',
    'pp',
    'pc',
    'e',
    'pc',
    'aOS',
    'aOB',
  ]);

  final Class builderInfoClass;
  Class visitedClass;
  final names = Set<String>();

  final dynamicNames = Set<String>();
  final CoreTypes coreTypes;
  final TransformationInfo info;
  final Member addMethod;

  _UnusedFieldMetadataPruner(this.builderInfoClass, this.addMethod,
      Set<Selector> dynamicSelectors, this.coreTypes, this.info) {
    dynamicNames.addAll(dynamicSelectors.map((sel) => sel.target.name));
  }

  /// If a proto message field is never accessed (neither read nor written to),
  /// remove its corresponding metadata in the construction of the Message._i
  /// field (i.e. the BuilderInfo metadata).
  void removeMetadataForUnusedFields(
      Set<Class> gmSubclasses,
      Map<Class, Set<Selector>> invokedMethods,
      CoreTypes coreTypes,
      TransformationInfo info) {
    for (final klass in gmSubclasses) {
      final selectors = invokedMethods[klass] ?? Set<Selector>();
      final builderInfoFields = klass.fields.where((f) => f.name.name == '_i');
      if (builderInfoFields.isEmpty) {
        continue;
      }
      final builderInfoField = builderInfoFields.single;
      _pruneBuilderInfoField(builderInfoField, selectors, klass);
    }
  }

  void _pruneBuilderInfoField(
      Field field, Set<Selector> selectors, Class gmSubclass) {
    names.clear();
    names.addAll(selectors.map((sel) => sel.target.name));
    visitedClass = gmSubclass;
    field.initializer.accept(this);
  }

  @override
  visitLet(Let node) {
    final initializer = node.variable.initializer;
    if (initializer is MethodInvocation &&
        initializer.interfaceTarget?.enclosingClass == builderInfoClass &&
        fieldAddingMethods.contains(initializer.name.name)) {
      final fieldName =
          (initializer.arguments.positional[1] as StringLiteral).value;
      final ucase = fieldName[0].toUpperCase() + fieldName.substring(1);
      // The name of the related `clear` method.
      final clearName = 'clear${ucase}';
      // The name of the related `has` method.
      final hasName = 'has${ucase}';

      bool nameIsUsed(String name) =>
          dynamicNames.contains(name) || names.contains(name);

      if (!(nameIsUsed(fieldName) ||
          nameIsUsed(clearName) ||
          nameIsUsed(hasName))) {
        if (info != null) {
          info.removedMessageFields.add("${visitedClass.name}.$fieldName");
        }

        // Replace the field metadata method with a dummy call to
        // `BuilderInfo.add`. This is to preserve the index calculations when
        // removing a field.
        // Change the tag-number to 0. Otherwise the decoder will get confused.
        initializer.interfaceTarget = addMethod;
        initializer.name = addMethod.name;
        initializer.arguments.replaceWith(
          Arguments(
            <Expression>[
              IntLiteral(0), // tagNumber
              NullLiteral(), // name
              NullLiteral(), // fieldType
              NullLiteral(), // defaultOrMaker
              NullLiteral(), // subBuilder
              NullLiteral(), // valueOf
              NullLiteral(), // enumValues
            ],
            types: <DartType>[InterfaceType(coreTypes.nullClass)],
          ),
        );
      }
    }
    node.body.accept(this);
  }
}

/// Finds all subclasses of [GeneratedMessage] and all methods invoked on them
/// (potentially in a dynamic call).
class InfoCollector extends RecursiveVisitor<void> {
  final dynamicSelectors = Set<Selector>();
  final Class generatedMessageClass;
  final gmSubclasses = Set<Class>();
  final gmSubclassesInvokedMethods = Map<Class, Set<Selector>>();

  InfoCollector(this.generatedMessageClass);

  @override
  visitClass(Class klass) {
    if (isGeneratedMethodSubclass(klass)) {
      gmSubclasses.add(klass);
    }
    return super.visitClass(klass);
  }

  @override
  visitMethodInvocation(MethodInvocation node) {
    if (node.interfaceTarget == null) {
      dynamicSelectors.add(Selector.doInvoke(node.name));
    }

    final targetClass = node.interfaceTarget?.enclosingClass;
    if (isGeneratedMethodSubclass(targetClass)) {
      addInvokedMethod(targetClass, Selector.doInvoke(node.name));
    }
    super.visitMethodInvocation(node);
  }

  @override
  visitPropertyGet(PropertyGet node) {
    if (node.interfaceTarget == null) {
      dynamicSelectors.add(Selector.doGet(node.name));
    }

    final targetClass = node.interfaceTarget?.enclosingClass;
    if (isGeneratedMethodSubclass(targetClass)) {
      addInvokedMethod(targetClass, Selector.doGet(node.name));
    }
    super.visitPropertyGet(node);
  }

  @override
  visitPropertySet(PropertySet node) {
    if (node.interfaceTarget == null) {
      dynamicSelectors.add(Selector.doSet(node.name));
    }

    final targetClass = node.interfaceTarget?.enclosingClass;
    if (isGeneratedMethodSubclass(targetClass)) {
      addInvokedMethod(targetClass, Selector.doSet(node.name));
    }
    super.visitPropertySet(node);
  }

  bool isGeneratedMethodSubclass(Class klass) {
    return klass?.superclass == generatedMessageClass;
  }

  void addInvokedMethod(Class klass, Selector selector) {
    final selectors =
        gmSubclassesInvokedMethods.putIfAbsent(klass, () => Set<Selector>());
    selectors.add(selector);
  }
}
