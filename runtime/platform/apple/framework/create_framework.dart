import 'dart:io';

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

void main(List<String> args) {
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

  // Copy headers.
  final headersDir = Directory('${frameworkDir.path}/Headers')..createSync();
  for (final headerFile in headerFiles) {
    final headerName = basename(headerFile.path);
    headerFile.copySync('${headersDir.path}/$headerName');
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
