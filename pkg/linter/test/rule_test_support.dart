// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/source/file_source.dart';
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/src/dart/analysis/byte_store.dart';
import 'package:analyzer/src/dart/analysis/driver_based_analysis_context.dart';
import 'package:analyzer/src/error/analyzer_error_code.dart';
import 'package:analyzer/src/lint/pub.dart';
import 'package:analyzer/src/lint/registry.dart';
import 'package:analyzer/src/lint/util.dart';
import 'package:analyzer/src/test_utilities/find_element.dart';
import 'package:analyzer/src/test_utilities/find_node.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:analyzer/src/test_utilities/resource_provider_mixin.dart';
import 'package:analyzer_utilities/test/experiments/experiments.dart';
import 'package:analyzer_utilities/test/mock_packages/mock_packages.dart';
import 'package:collection/collection.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/rules.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import 'mocks.dart';
import 'rule_test_support.dart';

export 'package:analyzer/src/dart/analysis/experiments.dart';
export 'package:analyzer/src/dart/error/syntactic_errors.dart';
export 'package:analyzer/src/error/codes.dart';
export 'package:analyzer/src/test_utilities/package_config_file_builder.dart';
export 'package:linter/src/lint_names.dart';

// TODO(srawlins): This is duplicate with
// pkg/analyzer/test/src/dart/resolution/context_collection_resolution.dart and
// and pkg/analysis_server/test/analysis_server_base.dart. Keep them as
// consistent with each other as they are today. Ultimately combine them in a
// shared analyzer test utilities package.
String analysisOptionsContent({
  List<String> experiments = const [],
  List<String> rules = const [],
  bool propagateLinterExceptions = false,
}) {
  var buffer = StringBuffer();

  if (experiments.isNotEmpty || propagateLinterExceptions) {
    buffer.writeln('analyzer:');
    buffer.writeln('  enable-experiment:');
    for (var experiment in experiments) {
      buffer.writeln('    - $experiment');
    }

    if (propagateLinterExceptions) {
      buffer.writeln('  optional-checks:');
      buffer.writeln(
        '    propagate-linter-exceptions: $propagateLinterExceptions',
      );
    }
  }

  buffer.writeln('linter:');
  buffer.writeln('  rules:');
  for (var rule in rules) {
    buffer.writeln('    - $rule');
  }

  return buffer.toString();
}

ExpectedError error(ErrorCode code, int offset, int length,
        {Pattern? messageContains}) =>
    ExpectedError(code, offset, length, messageContains: messageContains);

// TODO(srawlins): This is duplicate with
// pkg/analyzer/test/src/dart/resolution/context_collection_resolution.dart.
// Keep them as consistent with each other as they are today. Ultimately combine
// them in a shared analyzer test utilities package.
String pubspecYamlContent({String? name}) {
  var buffer = StringBuffer();

  if (name != null) {
    buffer.writeln('name: $name');
  }

  return buffer.toString();
}

typedef DiagnosticMatcher = bool Function(AnalysisError error);

/// A description of a diagnostic that is expected to be reported.
class ExpectedDiagnostic {
  final DiagnosticMatcher _diagnosticMatcher;

  /// The offset of the beginning of the diagnostic's region.
  final int _offset;

  /// The offset of the beginning of the diagnostic's region.
  final int _length;

  /// A pattern that should be contained in the diagnostic message or `null` if
  /// the message contents should not be checked.
  final Pattern? _messageContains;

  /// Initialize a newly created diagnostic description.
  ExpectedDiagnostic(this._diagnosticMatcher, this._offset, this._length,
      {Pattern? messageContains})
      : _messageContains = messageContains;

  /// Whether the [error] matches this description of what it's expected to be.
  bool matches(AnalysisError error) {
    if (!_diagnosticMatcher(error)) return false;
    if (error.offset != _offset) return false;
    if (error.length != _length) return false;
    if (_messageContains != null && !error.message.contains(_messageContains)) {
      return false;
    }

    return true;
  }
}

/// A description of an expected error.
class ExpectedError extends ExpectedDiagnostic {
  final ErrorCode _code;

  ExpectedError(this._code, int offset, int length, {Pattern? messageContains})
      : super((error) => error.errorCode == _code, offset, length,
            messageContains: messageContains);
}

/// A description of an expected lint rule violation.
class ExpectedLint extends ExpectedDiagnostic {
  final String _lintName;

  ExpectedLint(this._lintName, int offset, int length,
      {Pattern? messageContains})
      : super((error) => error.errorCode.name == _lintName, offset, length,
            messageContains: messageContains);

  ExpectedLint.withLintCode(LintCode lintCode, int offset, int length,
      {Pattern? messageContains})
      : _lintName = lintCode.uniqueName,
        super((error) => error.errorCode == lintCode, offset, length,
            messageContains: messageContains);
}

mixin LanguageVersion219Mixin on PubPackageResolutionTest {
  @override
  String? get testPackageLanguageVersion => '2.19';
}

abstract class LintRuleTest extends PubPackageResolutionTest {
  String get lintRule;

  @override
  List<String> get _lintRules {
    var ruleName = lintRule;
    if (!Registry.ruleRegistry.any((r) => r.name == ruleName)) {
      throw Exception("Unrecognized rule: '$ruleName'");
    }
    return [ruleName];
  }

  ExpectedLint lint(int offset, int length, {Pattern? messageContains}) =>
      ExpectedLint(lintRule, offset, length, messageContains: messageContains);
}

class PubPackageResolutionTest extends _ContextResolutionTest {
  final List<String> _lintRules = const [];

  bool get addFixnumPackageDep => false;

  bool get addFlutterPackageDep => false;

  bool get addJsPackageDep => false;

  bool get addKernelPackageDep => false;

  bool get addMetaPackageDep => false;

  bool get dumpAstOnFailures => true;

  List<String> get experiments => experimentsForTests;

  List<String> get lintRules => _lintRules;

  String get testFileName => 'test.dart';

  @override
  String get testFilePath => '$testPackageLibPath/$testFileName';

  String? get testPackageLanguageVersion => null;

  String get testPackageLibPath => '$testPackageRootPath/lib';

  String get testPackagePubspecPath => '$testPackageRootPath/pubspec.yaml';

  String get testPackageRootPath => '$workspaceRootPath/test';

  String get workspaceRootPath => '/home';

  @override
  List<String> get _collectionIncludedPaths => [workspaceRootPath];

  /// Asserts that the number of diagnostics reported in [content] matches the
  /// number of [expectedDiagnostics] and that they have the expected error
  /// descriptions and locations.
  ///
  /// The order in which the diagnostics were gathered is ignored.
  Future<void> assertDiagnostics(
      String content, List<ExpectedDiagnostic> expectedDiagnostics) async {
    addTestFile(content);
    await resolveTestFile();
    await assertDiagnosticsIn(errors, expectedDiagnostics);
  }

  /// Asserts that the diagnostics in [errors] match [expectedDiagnostics].
  Future<void> assertDiagnosticsIn(List<AnalysisError> errors,
      List<ExpectedDiagnostic> expectedDiagnostics) async {
    //
    // Match actual diagnostics to expected diagnostics.
    //
    var unmatchedActual = errors.toList();
    var unmatchedExpected = expectedDiagnostics.toList();
    var actualIndex = 0;
    while (actualIndex < unmatchedActual.length) {
      var matchFound = false;
      var expectedIndex = 0;
      while (expectedIndex < unmatchedExpected.length) {
        if (unmatchedExpected[expectedIndex]
            .matches(unmatchedActual[actualIndex])) {
          matchFound = true;
          unmatchedActual.removeAt(actualIndex);
          unmatchedExpected.removeAt(expectedIndex);
          break;
        }
        expectedIndex++;
      }
      if (!matchFound) {
        actualIndex++;
      }
    }
    //
    // Write the results.
    //
    var buffer = StringBuffer();
    if (unmatchedExpected.isNotEmpty) {
      buffer.writeln('Expected but did not find:');
      for (var expected in unmatchedExpected) {
        buffer.write('  ');
        if (expected is ExpectedError) {
          buffer.write(expected._code);
        }
        if (expected is ExpectedLint) {
          buffer.write(expected._lintName);
        }
        buffer.write(' [');
        buffer.write(expected._offset);
        buffer.write(', ');
        buffer.write(expected._length);
        buffer.writeln(']');
      }
    }
    if (unmatchedActual.isNotEmpty) {
      if (buffer.isNotEmpty) {
        buffer.writeln();
      }
      buffer.writeln('Found but did not expect:');
      for (var actual in unmatchedActual) {
        buffer.write('  ');
        buffer.write(actual.errorCode);
        buffer.write(' [');
        buffer.write(actual.offset);
        buffer.write(', ');
        buffer.write(actual.length);
        buffer.write(', ');
        buffer.write(actual.message);
        buffer.writeln(']');
      }
    }
    if (buffer.isNotEmpty) {
      errors.sort((first, second) => first.offset.compareTo(second.offset));
      buffer.writeln();
      buffer.writeln('To accept the current state, expect:');
      for (var actual in errors) {
        late String diagnosticKind;
        Object? description;
        if (actual.errorCode is LintCode) {
          diagnosticKind = 'lint';
        } else {
          diagnosticKind = 'error';
          description = actual.errorCode;
        }
        buffer.write('  $diagnosticKind(');
        if (description != null) {
          buffer.write(description);
          buffer.write(', ');
        }
        buffer.write(actual.offset);
        buffer.write(', ');
        buffer.write(actual.length);
        buffer.writeln('),');
      }

      if (dumpAstOnFailures) {
        buffer.writeln();
        buffer.writeln();
        try {
          var astSink = CollectingSink();

          StringSpelunker(result.unit.toSource(),
                  sink: astSink, featureSet: result.unit.featureSet)
              .spelunk();
          buffer.write(astSink.buffer);
          buffer.writeln();
          // I hereby choose to catch this type.
          // ignore: avoid_catching_errors
        } on ArgumentError catch (_) {
          // Perhaps we encountered a parsing error while spelunking.
        }
      }

      fail(buffer.toString());
    }
  }

  /// Asserts that the number of diagnostics that have been gathered at [path]
  /// matches the number of [expectedDiagnostics] and that they have the
  /// expected error descriptions and locations.
  ///
  /// The order in which the diagnostics were gathered is ignored.
  Future<void> assertDiagnosticsInFile(
      String path, List<ExpectedDiagnostic> expectedDiagnostics) async {
    await _resolveFile(path);
    await assertDiagnosticsIn(errors, expectedDiagnostics);
  }

  /// Asserts that the diagnostics for each `path` match those in the paired
  /// `expectedDiagnostics`.
  ///
  /// The unit at each path needs to have already been written to the file
  /// system before calling this method.
  Future<void> assertDiagnosticsInUnits(
      List<(String path, List<ExpectedDiagnostic> expectedDiagnostics)>
          unitsAndDiagnostics) async {
    for (var (path, expectedDiagnostics) in unitsAndDiagnostics) {
      result = await resolveFile(convertPath(path));
      await assertDiagnosticsIn(result.errors, expectedDiagnostics);
    }
  }

  /// Asserts that there are no diagnostics in the given [content].
  Future<void> assertNoDiagnostics(String content) async =>
      assertDiagnostics(content, const []);

  /// Asserts that there are no diagnostics in [errors].
  Future<void> assertNoDiagnosticsIn(List<AnalysisError> errors) =>
      assertDiagnosticsIn(errors, const []);

  /// Asserts that there are no diagnostics in the file at the given [path].
  Future<void> assertNoDiagnosticsInFile(String path) async =>
      assertDiagnosticsInFile(path, const []);

  /// Asserts that no diagnostics are reported when resolving [content].
  Future<void> assertNoPubspecDiagnostics(String content) async {
    newFile(testPackagePubspecPath, content);
    var errors = await _resolvePubspecFile(content);
    await assertDiagnosticsIn(errors, []);
  }

  /// Asserts that [expectedDiagnostics] are reported when resolving [content].
  Future<void> assertPubspecDiagnostics(
      String content, List<ExpectedDiagnostic> expectedDiagnostics) async {
    newFile(testPackagePubspecPath, content);
    var errors = await _resolvePubspecFile(content);
    await assertDiagnosticsIn(errors, expectedDiagnostics);
  }

  @override
  @mustCallSuper
  void setUp() {
    super.setUp();
    // Check for any needlessly enabled experiments.
    for (var experiment in experiments) {
      var feature = ExperimentStatus.knownFeatures[experiment];
      if (feature?.isEnabledByDefault ?? false) {
        fail("The '$experiment' experiment is enabled by default, "
            'try removing it from `experiments`.');
      }
    }

    newAnalysisOptionsYamlFile(
      testPackageRootPath,
      analysisOptionsContent(
        experiments: experiments,
        rules: _lintRules,
        propagateLinterExceptions: true,
      ),
    );
    writeTestPackageConfig(
      PackageConfigFileBuilder(),
    );
    _writeTestPackagePubspecYamlFile(pubspecYamlContent(name: 'test'));
  }

  void writePackageConfig(String path, PackageConfigFileBuilder config) {
    newFile(
      path,
      config.toContent(
        toUriStr: toUriStr,
      ),
    );
  }

  void writeTestPackageConfig(PackageConfigFileBuilder config) {
    var configCopy = config.copy();

    configCopy.add(
      name: 'test',
      rootPath: testPackageRootPath,
      languageVersion: testPackageLanguageVersion,
    );

    if (addFixnumPackageDep) {
      var fixnumPath = addFixnum().parent.path;
      configCopy.add(name: 'fixnum', rootPath: fixnumPath);
    }

    if (addFlutterPackageDep) {
      var uiPath = addUI().parent.path;
      configCopy.add(name: 'ui', rootPath: uiPath);

      var flutterPath = addFlutter().parent.path;
      configCopy.add(name: 'flutter', rootPath: flutterPath);
    }

    if (addJsPackageDep) {
      var jsPath = addJs().parent.path;
      configCopy.add(name: 'js', rootPath: jsPath);
    }

    if (addKernelPackageDep) {
      var kernelPath = addKernel().parent.path;
      configCopy.add(name: 'kernel', rootPath: kernelPath);
    }

    if (addMetaPackageDep) {
      var metaPath = addMeta().parent.path;
      configCopy.add(name: 'meta', rootPath: metaPath);
    }

    var path = '$testPackageRootPath/.dart_tool/package_config.json';
    writePackageConfig(path, configCopy);
  }

  Future<List<AnalysisError>> _resolvePubspecFile(String content) async {
    var path = convertPath(testPackagePubspecPath);
    var pubspecRules = <LintRule, PubspecVisitor<Object?>>{};
    for (var rule in Registry.ruleRegistry
        .where((rule) => _lintRules.contains(rule.name))) {
      var visitor = rule.getPubspecVisitor();
      if (visitor != null) {
        pubspecRules[rule] = visitor;
      }
    }

    if (pubspecRules.isEmpty) {
      throw UnsupportedError(
          'Resolving pubspec files only supported with rules with '
          'PubspecVisitors.');
    }

    var sourceUri = resourceProvider.pathContext.toUri(path);
    var pubspecAst = Pubspec.parse(content,
        sourceUrl: sourceUri, resourceProvider: resourceProvider);
    var listener = RecordingErrorListener();
    var file = resourceProvider.getFile(path);
    var reporter = ErrorReporter(
      listener,
      FileSource(file, sourceUri),
    );
    for (var entry in pubspecRules.entries) {
      entry.key.reporter = reporter;
      pubspecAst.accept(entry.value);
    }
    return [...listener.errors];
  }

  void _writeTestPackagePubspecYamlFile(String content) {
    newPubspecYamlFile(testPackageRootPath, content);
  }
}

abstract class _ContextResolutionTest
    with MockPackagesMixin, ResourceProviderMixin {
  static bool _lintRulesAreRegistered = false;

  /// The byte store that is reused between tests. This allows reusing all
  /// unlinked and linked summaries for SDK, so that tests run much faster.
  /// However nothing is preserved between Dart VM runs, so changes to the
  /// implementation are still fully verified.
  static final MemoryByteStore _sharedByteStore = MemoryByteStore();

  final MemoryByteStore _byteStore = _sharedByteStore;

  AnalysisContextCollectionImpl? _analysisContextCollection;

  late FindElement findElement;

  late FindNode findNode;

  late ResolvedUnitResult result;

  /// The analysis errors that were computed during analysis.
  List<AnalysisError> get errors => result.errors
      .whereNot((e) => ignoredErrorCodes.any((c) => e.errorCode == c))
      .toList();

  /// Error codes that by default should be ignored in test expectations.
  List<AnalyzerErrorCode> get ignoredErrorCodes =>
      [WarningCode.UNUSED_LOCAL_VARIABLE];

  /// The path to the root of the external packages.
  @override
  String get packagesRootPath => '/packages';

  String get testFilePath;

  List<String> get _collectionIncludedPaths;

  Folder get _sdkRoot => newFolder('/sdk');

  void addTestFile(String content) {
    newFile(testFilePath, content);
  }

  @override
  File newFile(String path, String content) {
    if (_analysisContextCollection != null && !path.endsWith('.dart')) {
      throw StateError('Only dart files can be changed after analysis.');
    }

    return super.newFile(path, content);
  }

  /// Resolves a Dart source file at [path].
  ///
  /// [path] must be converted for this file system.
  Future<ResolvedUnitResult> resolveFile(String path) async {
    var analysisContext = _contextFor(path);
    var session = analysisContext.currentSession;
    var result = await session.getResolvedUnit(path) as ResolvedUnitResult;

    findElement = FindElement(result.unit);
    findNode = FindNode(result.content, result.unit);
    return result;
  }

  Future<void> resolveTestFile() => _resolveFile(testFilePath);

  @mustCallSuper
  void setUp() {
    if (!_lintRulesAreRegistered) {
      registerLintRules();
      _lintRulesAreRegistered = true;
    }

    createMockSdk(
      resourceProvider: resourceProvider,
      root: _sdkRoot,
    );
  }

  @mustCallSuper
  Future<void> tearDown() async {
    await _analysisContextCollection?.dispose();
    _analysisContextCollection = null;
  }

  DriverBasedAnalysisContext _contextFor(String path) {
    _createAnalysisContexts();

    var convertedPath = convertPath(path);
    return _analysisContextCollection!.contextFor(convertedPath);
  }

  /// Creates all analysis contexts in [_collectionIncludedPaths].
  void _createAnalysisContexts() {
    if (_analysisContextCollection != null) {
      return;
    }

    _analysisContextCollection = AnalysisContextCollectionImpl(
      byteStore: _byteStore,
      declaredVariables: {},
      enableIndex: true,
      includedPaths: _collectionIncludedPaths.map(convertPath).toList(),
      resourceProvider: resourceProvider,
      sdkPath: _sdkRoot.path,
    );
  }

  /// Resolves the file with the [path] into [result].
  Future<void> _resolveFile(String path) async {
    var convertedPath = convertPath(path);

    result = await resolveFile(convertedPath);
  }
}
