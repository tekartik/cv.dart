@TestOn('vm')
library;

import 'dart:io';

import 'package:cv/cv.dart';
import 'package:cv/src/version.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

var pubspecMap = asModel(
  loadYaml(File('pubspec.yaml').readAsStringSync()) as Map,
);
void main() {
  test('version', () {
    var version = Version.parse(pubspecMap['version'] as String);
    expect(version, packageVersion);
  });
}
