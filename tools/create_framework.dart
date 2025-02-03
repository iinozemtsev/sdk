import 'dart:io';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:path/path.dart';

final parser = ArgParser()
  ..addOption('output', help: 'Framework output folder')
  ..addOption('library', help: 'Path to shared library')
  ..addMultiOption('headers', help: 'Header files to include')
  ..addMultiOption('resources',
      help: 'Extra files to pack into framework. Format: src:dest')
  ..addOption('framework_name', defaultsTo: 'Dart')
  ..addFlag('create_umbrella_header',
      defaultsTo: false,
      help: 'Whether to generate an umbrella header from the list of headers');

void dprint(String message) {
  File('/tmp/create_framework_log.txt').writeAsStringSync('$message\n', mode: FileMode.append);
}

String rewriteIncludes(String content) {
  final includePattern = RegExp(r'^#include ".*/([^/]+\.h)"');
  final transformedLines = <String>[];
  for (final line in LineSplitter.split(content)) {
    final match = includePattern.firstMatch(line);
    if (match == null) {
      transformedLines.add(line);
    } else {
      transformedLines.add('#include "${match.group(1)!}"');
    }
  }
  return transformedLines.join('\n') + '\n';
}

void main(List<String> args) {
  dprint('Hi there!');
  final flags = parser.parse(args);

  final createUmbrellaHeader = flags['create_umbrella_header'] as bool;
  final frameworkName = flags['framework_name'] as String;
  final output = flags['output'] as String;
  final headerFiles = [
    for (final header in flags['headers'] as List<String>) File(header)
  ];
  final libFile = File(flags['library'] as String);

  final frameworkDir = Directory(output);
  if (frameworkDir.existsSync()) {
    frameworkDir.deleteSync(recursive: true);
  }
  frameworkDir.createSync(recursive: true);

  // Copy library
  libFile.copySync('$output/$frameworkName');

  // Change install path
  final installNameToolResult = Process.runSync('/usr/bin/install_name_tool', ['-id', '@rpath/$frameworkName.framework/$frameworkName', '$output/$frameworkName']);
  if (installNameToolResult.exitCode != 0) {
    stderr.writeln('istall_name_tool failed. ExitCode: ${installNameToolResult.exitCode}\nStderr:\n${installNameToolResult.stderr}\nStdout:\n${installNameToolResult.stdout}');
    exit(1);
}

  // Copy headers.
  final headersDir = Directory('${frameworkDir.path}/Headers')..createSync();
  for (final headerFile in headerFiles) {
    final headerName = basename(headerFile.path);
    final headerContent = rewriteIncludes(headerFile.readAsStringSync());
    File('${headersDir.path}/$headerName').writeAsStringSync(headerContent);
  }

  if (createUmbrellaHeader) {
    // Write umbrella header.
    final umbrellaHeader = File('${headersDir.path}/$frameworkName.h');
    umbrellaHeader.writeAsStringSync([
          for (final headerFile in headerFiles)
            '#import <$frameworkName/${basename(headerFile.path)}>'
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

  for (final resourceSpec in flags['resources'] as List<String>) {
    final [srcPath, destPath] = resourceSpec.split(':');
    // Dest path must be relative to Framework dir.
    final dest = '$output/$destPath';
    Directory(dirname(dest)).createSync(recursive: true);
    File(srcPath).copySync(dest);
  }
}
