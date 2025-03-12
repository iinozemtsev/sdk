import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:vm/embedder/visitor.dart' as visitor show visitLibrary;
import 'package:front_end/src/api_prototype/compiler_options.dart'
    show Verbosity;
import 'package:dart2native/generate.dart';
import 'package:kernel/kernel.dart' show loadComponentFromBinary, Library;
import 'package:path/path.dart' as path;
import 'package:args/args.dart';
import 'package:vm/embedder/visitor.dart';
import 'package:vm/embedder/writer.dart' show EntryPointShimWriter;

import '../core.dart';
import 'compile.dart' show compileErrorExitCode;

class AssembleCommand extends DartdevCommand {
  static const String cmdName = 'assemble';

  AssembleCommand({bool verbose = false})
      : super(cmdName, 'Assemble Dart snapshot for Engine', verbose) {
    argParser..addOption(
      'output',
      help: 'Output directory',
      abbr: 'o',
    )..addFlag('skip_codegen');
  }

  @override
  FutureOr<int> run() async {
    final args = argResults!;
    final String sourcePath;
    if (args.rest.isEmpty) {
      sourcePath = 'bin/main.dart';
    } else if (args.rest.length > 1) {
      usageException('Unexpected arguments after Dart entry point.');
    } else {
      sourcePath = args.rest[0];
    }

    final String outputPath = args.option('output') ?? 'out';

    Directory(outputPath).createSync(recursive: true);
    // Shortcut!
    final kernelFileName = 'counter_logic.dill';
    final kernelPath = '$outputPath/$kernelFileName';

    print('Generating kernel to $kernelPath...');
    try {
      await generateKernel(
        sourceFile: sourcePath,
        outputFile: kernelPath,
        defines: [],
        packages: null,
        enableExperiment: '',
        linkPlatform: true,
        depFile: null,
        extraOptions: [],
        embedSources: false,
        verbose: verbose,
        verbosity: Verbosity.defaultValue,
      );
    } catch (e, st) {
      log.stderr(e.toString());
      if (verbose) {
        log.stderr(st.toString());
      }
      return compileErrorExitCode;
    }

    print('Generating bindings...');
    if (!args.flag('skip_codegen')) {
      await generateShims(outputPath, kernelPath);
    }
    print('Building shared library...');
    await buildSharedLibrary('$outputPath/counter_logic');
    print('Packaging framework...');
    await createFramework(
        outputDirectory: outputPath,
        basename: 'counter_logic',
        frameworkName: 'CounterLogic');
    print('Copying Dart.framework...');
    Process.runSync('cp', [
      '-R',
      '/Users/iinozemtsev/work/cache/watchos_simulator/Dart.framework',
      '$outputPath/watchos_simulator/Frameworks'
    ]);
    return 0;
  }

  Future<void> createFramework(
      {required String outputDirectory,
      required String basename,
      required String frameworkName}) async {
    // Shortcut!
    final createUmbrellaHeader = true;
    final headerFiles = [File('$outputDirectory/$basename.h')];
    final libFile = File('$outputDirectory/$basename.dylib');

    final output =
        '$outputDirectory/watchos_simulator/Frameworks/$frameworkName.framework';
    final frameworkDir = Directory(output);
    if (frameworkDir.existsSync()) {
      frameworkDir.deleteSync(recursive: true);
    }
    frameworkDir.createSync(recursive: true);

    // Copy library
    libFile.copySync('$output/$frameworkName');

    // Change install path
    final installNameToolResult =
        Process.runSync('/usr/bin/install_name_tool', [
      '-id',
      '@rpath/$frameworkName.framework/$frameworkName',
      '$output/$frameworkName'
    ]);
    if (installNameToolResult.exitCode != 0) {
      stderr.writeln(
          'istall_name_tool failed. ExitCode: ${installNameToolResult.exitCode}\nStderr:\n${installNameToolResult.stderr}\nStdout:\n${installNameToolResult.stdout}');
      exit(1);
    }

    // Copy headers.
    final headersDir = Directory('${frameworkDir.path}/Headers')..createSync();
    for (final headerFile in headerFiles) {
      final headerName = path.basename(headerFile.path);
      final headerContent = rewriteIncludes(headerFile.readAsStringSync());
      File('${headersDir.path}/$headerName').writeAsStringSync(headerContent);
    }

    if (createUmbrellaHeader) {
      // Write umbrella header.
      final umbrellaHeader = File('${headersDir.path}/$frameworkName.h');
      umbrellaHeader.writeAsStringSync([
            for (final headerFile in headerFiles)
              '#import <$frameworkName/${path.basename(headerFile.path)}>'
          ].join('\n') +
          '\n');
    }

    // Write modulemap
    final modulesDir = Directory('${frameworkDir.path}/Modules')..createSync();
    final moduleMapFile = File('${modulesDir.path}/module.modulemap');
    moduleMapFile.writeAsStringSync('''
framework module $frameworkName {
  umbrella header "$frameworkName.h"
  export *
  module * { export * }
}
''');

    // Write Info.plist
    final infoPlistFile = File('${frameworkDir.path}/Info.plist');
    infoPlistFile.writeAsStringSync('''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>$frameworkName</string>
	<key>CFBundleIdentifier</key>
	<string>dev.dart.$frameworkName</string>
</dict>
</plist>
''');

    final kernel = '$outputDirectory/$basename.dill';
    final kernelDest = '${frameworkDir.path}/assets/snapshot';
    Directory(path.dirname(kernelDest)).createSync(recursive: true);
    File(kernel).copySync(kernelDest);
  }

  Future<void> generateShims(String outputDirectory, String kernelFile) async {
    final component = loadComponentFromBinary(kernelFile);
    Library? library;
    for (final l in component.libraries) {
      // Shortcut!!!
      if (l.fileUri.path.endsWith('src/counter.dart')) {
        library = l;
      }
    }
    final collector = visitor.visitLibrary(component, library!,
        createUninitializedInstanceMethods: true);
    final declarations = StringBuffer();
    final definitions = StringBuffer();

    // Shortcut!
    final basePath = '$outputDirectory/counter_logic';

    final headerFile = File('$basePath.h');

    final writer = EntryPointShimWriter(headerFile.path, library, collector);
    writer.write(declarations, definitions);

    if (headerFile.existsSync()) {
      print("Header file '${headerFile.path}' already exists");
      exit(1);
    }
    headerFile.writeAsStringSync(declarations.toString(), flush: true);

    final implFile = File('$basePath.cc');
    if (implFile.existsSync()) {
      print("Implementation file '${implFile.path}' already exists");
      exit(1);
    }
    implFile.writeAsStringSync(definitions.toString(), flush: true);
  }

  Future<void> buildSharedLibrary(String basePath) async {
    // Shortcut!
    final result = Process.runSync(
        '/Users/iinozemtsev/work/cache/build_framework.sh', [basePath],
        runInShell: true);
    if (result.exitCode != 0) {
      print('Shared library process result:');
      print('Exit code: ${result.exitCode}');
      print('--- Stdout ---');
      print(result.stdout);
      print('--- Stderr ---');
      print(result.stderr);
    }
  }
}

String rewriteIncludes(String content) {
  final includePattern = RegExp(r'^#include ".*/([^/]+\.h)"');
  final transformedLines = <String>[];
  for (final line in LineSplitter.split(content)) {
    final match = includePattern.firstMatch(line);
    if (match == null) {
      transformedLines.add(line);
    } else {
      transformedLines.add('#include "Dart/Dart.h"');
    }
  }
  return transformedLines.join('\n') + '\n';
}
