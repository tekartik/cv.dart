import 'package:dev_test/package.dart';
import 'package:path/path.dart';

Future main() async {
  for (var dir in [
    'cv',
  ]) {
    await packageRunCi(join('..', 'packages', dir));
  }
}
