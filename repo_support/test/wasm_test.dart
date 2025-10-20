@TestOn('vm')
library;

import 'package:dev_build/shell.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

var cvPackageDirPath = join('..', 'packages', 'cv');
Future main() async {
  test(
    'Run CV package tests with dart2wasm',
    () async {
      var shell = Shell(workingDirectory: cvPackageDirPath);
      await shell.run('dart test -p chrome --compiler dart2wasm');
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
