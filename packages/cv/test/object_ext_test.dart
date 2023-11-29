import 'package:cv/cv.dart';

// ignore: unused_import
import 'package:cv/src/typedefs.dart';
import 'package:test/test.dart';

List<Map> get listWithOneEmptyModel => [{}];

void main() {
  group('ModelRawObjectExt', () {
    test('anyAs', () {
      int? i = 1;
      expect(i.anyAs<int>(), 1);
      expect(i.anyAs<String?>(), isNull);
      try {
        1.anyAs<String>();
        fail('should fail');
      } on TestFailure catch (_) {
        rethrow;
      } catch (_) {}
      i = null;
      expect(i?.anyAs<int?>(), isNull);
      expect(i?.anyAs<String?>(), isNull);
    });
  });
}
