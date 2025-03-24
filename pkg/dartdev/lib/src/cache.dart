import 'dart:io' show HttpClient, HttpStatus, Platform, Process, exit, stderr;
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/local.dart';

import 'sdk.dart';

class Cache {
  final FileSystem fs;
  late final Directory directory;

  Cache(String directoryPath, {FileSystem? fs, Directory? temp})
      : fs = fs ?? LocalFileSystem() {
    directory = this.fs.directory(directoryPath);
  }

  Future<String> ensure(Artifact artifact) async {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    final destinationFile = directory.childFile(artifact.fileName);
    await _ensureDownloaded(destinationFile, artifact.uris);
    _ensureExecutable(destinationFile, artifact);
    return destinationFile.path;
  }

  void _ensureExecutable(File destinationFile, Artifact artifact) {
    if (Platform.isWindows || !artifact.isExecutable) {
      return;
    }

    // Check S_IXUSR bit.
    final isUserExecutable = destinationFile.statSync().mode & 0x40 == 0x40;
    if (isUserExecutable) {
      return;
    }

    final chmodResult = Process.runSync('chmod', ['a+x', destinationFile.path]);
    if (chmodResult.exitCode != 0) {
      stderr.writeln(
          'Cannot make ${destinationFile.path} executable, chmod failed');
      stderr.writeln('exitCode: ${chmodResult.exitCode}');
      stderr.writeln(chmodResult.stderr);
      exit(128);
    }
  }

  Future<void> _ensureDownloaded(File destinationFile, List<Uri> uris) async {
    if (destinationFile.existsSync()) {
      return;
    }
    final httpClient = HttpClient();
    try {
      for (var uri in uris) {
        final request = await httpClient.getUrl(uri);
        final response = await request.close();
        if (response.statusCode == HttpStatus.notFound) {
          continue;
        }

        if (response.statusCode != HttpStatus.ok) {
          throw Exception(response.statusCode);
        }

        final buffer = BytesBuilder();
        await for (final chunk in response) {
          buffer.add(chunk);
        }
        destinationFile.writeAsBytesSync(buffer.takeBytes());
        return;
      }
    } finally {
      httpClient.close(force: true);
    }
    _printDownloadErrorAndExit(destinationFile.path, uris);
  }

  Never _printDownloadErrorAndExit(String destinationPath, List<Uri> uris) {
    if (uris.length == 1) {
      stderr.writeln('Failed to download $destinationPath from ${uris.single}');
      stderr.writeln('If the problem persists, try to download it manually.');
      exit(128);
    } else {
      stderr.writeln(
          'Failed to download $destinationPath from any of these URIs:');
      for (final uri in uris) {
        stderr.writeln('- $uri');
      }
    }
    stderr.writeln('If the problem persists, try to download it manually.');
    exit(128);
  }
}

/// Downloadable artifact.
class Artifact {
  final String fileName;
  final List<Uri> uris;
  final bool isExecutable;

  const Artifact(
      {required this.fileName, required this.uris, required this.isExecutable});
}

Artifact genSnapshotArtifact(String targetPlatform,
        [bool fallbackToLatest = false]) =>
    _sdkArtifact(targetPlatform, (h, t, ext) => 'gen_snapshot_${h}_$t$ext');

Artifact dartaotruntimeArtifact(String targetPlatform,
        [bool fallbackToLatest = false]) =>
    _sdkArtifact(targetPlatform, (h, t, ext) => 'dartaotruntime_$t$ext');

Artifact _sdkArtifact(String targetPlatform,
    String Function(String host, String target, String ext) generateName) {
  final extendedVersion = ExtendedVersion.current;
  final fileName = generateName(extendedVersion.platform, targetPlatform,
      Platform.isWindows ? '.exe' : '');

  final channel = extendedVersion.channel;
  final version = extendedVersion.version;

  final paths = <String>[];
  // The URI is channel-dependent, see
  // https://dart.dev/get-dart/archive#download-urls.
  if (extendedVersion.channel == 'main') {
    paths.addAll([
      'dart-archive/channels/main/raw/${extendedVersion.commitId}/sdk/$fileName',
      'dart-archive/channels/main/raw/latest/sdk/$fileName',
    ]);
  } else if (extendedVersion.channel == 'dev') {
    paths.addAll([
      'dart-archive/channels/dev/release/$version/sdk/$fileName',
      'dart-archive/channels/dev/signed/$version/sdk/$fileName',
      'dart-archive/channels/dev/raw/$version/sdk/$fileName',
    ]);
  } else {
    paths.add('dart-archive/channels/$channel/release/$version/sdk/$fileName');
  }

  return Artifact(
      fileName: fileName,
      uris: paths
          .map((p) =>
              Uri(scheme: 'https', host: 'storage.googleapis.com', path: p))
          .toList(),
      isExecutable: true);
}
