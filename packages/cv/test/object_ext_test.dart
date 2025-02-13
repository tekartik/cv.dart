import 'package:cv/cv.dart';

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
    test('anyDeepClone', () {
      expect(1.anyDeepClone<int>(), 1);
      var map = {
        'a': 1,
        'b': [1, 2],
        'c': {'d': 1},
      };
      var newMap = map.anyDeepClone<Model>();
      expect(newMap, map);
      expect(newMap, isNot(same(map)));
    });
  });
}
