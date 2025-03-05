// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:kernel/ast.dart' show Library;
import 'package:kernel/core_types.dart' show CoreTypes;
import 'package:kernel/kernel.dart' show Component, loadComponentFromBinary;
import 'package:path/path.dart' as path;
import 'package:vm/embedder/visitor.dart' as visitor show visitLibrary;
import 'package:vm/embedder/writer.dart' show EntryPointShimWriter;

final String _usage = '''
Usage: generate_entry_point_shims [options] source.dill out/basename

Creates appropriate entry point shims for the entry points in the component
encoded by the provided dill. If the component has a main method, then only
translates entry points in the same package as the main method, otherwise
requires a package to be specified via the command-line options.

out/basename.h contains the declarations of the shim functions and
out/basename.cc contains the definitions.

Options:
''';

void main(List<String> args) async {
  final parser =
      ArgParser()
        ..addFlag(
          'uninitialized',
          abbr: 'u',
          help:
              'Create allocation and initializion methods for uninitialized instances',
        )
        ..addFlag(
          'error-unhandled',
          abbr: 'e',
          help: 'Error for entry points that cannot be shimmed',
        )
        ..addFlag(
          'help',
          abbr: 'h',
          help: 'Prints usage information and exits',
          negatable: false,
        )
        ..addOption(
          'package',
          abbr: 'p',
          help: 'Consider entry points only from the specified package',
          valueHelp: 'URI',
        );

  Never usageFail([String? prefix]) {
    if (prefix != null) {
      print(prefix);
      print('');
    }
    print(_usage);
    print(parser.usage);
    exit(1);
  }

  final argResults = parser.parse(args);
  if (argResults['help'] || argResults.rest.length != 2) {
    usageFail();
  }

  final relativePath = path.normalize(argResults.rest[1]);
  final outputDir = Directory(path.dirname(relativePath));
  if (!outputDir.existsSync()) {
    print("Directory '${outputDir.path}' does not exist");
    exit(1);
  }

  final source = args[0];
  final component = loadComponentFromBinary(argResults.rest[0]);
  Library? library;

  final uriString = argResults['package'];
  if (uriString == null) {
    final mainMethod = component.mainMethod;
    if (mainMethod == null) {
      usageFail('No main method found, so -p/--package is required.');
    }
  } else {
    final uri = Uri.tryParse(uriString);
    if (uri == null) {
      usageFail('${argResults['package']} is not a valid URI.');
    }
    for (final l in component.libraries) {
      if (l.importUri == uri) {
        library = l;
        break;
      }
    }
    if (library == null) {
      usageFail('No package found with URI ${argResults['package']}.');
    }
  }

  final collector = visitor.visitLibrary(
    component,
    library ?? component.mainMethod!.enclosingLibrary,
    createUninitializedInstanceMethods: argResults['uninitialized'],
    errorOnUnhandledEntryPoints: argResults['error-unhandled'],
  );

  final declarations = StringBuffer();
  final definitions = StringBuffer();

  final headerFile = File(relativePath + '.h');

  final writer = EntryPointShimWriter(headerFile.path, library, collector);
  writer.write(declarations, definitions);

  if (headerFile.existsSync()) {
    print("Header file '${headerFile.path}' already exists");
    exit(1);
  }
  headerFile.writeAsStringSync(declarations.toString(), flush: true);

  final implFile = File(relativePath + '.cc');
  if (implFile.existsSync()) {
    print("Implementation file '${implFile.path}' already exists");
    exit(1);
  }
  implFile.writeAsStringSync(definitions.toString(), flush: true);
}
