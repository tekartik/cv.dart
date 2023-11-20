import 'package:cv/cv.dart';
// ignore: unused_import
import 'package:cv/src/typedefs.dart';
import 'package:test/test.dart';

List<Map> get listWithOneEmptyModel => [{}];
void main() {
  group('getValue', () {
    test('value', () {
      var map = {
        'test': {
          'sub': ['a', 'b']
        }
      };
      expect(map.getKeyPathValue(['test', 'sub', 1]), 'b');
      expect(map.getKeyPathValue<int>(['test', 'sub', 1]), isNull);
      expect(map.getKeyPathValue<String>(['test', 'sub', 1]), 'b');
      expect(map.getKeyPathValue(['test', 'sub', 2]), isNull);
      expect(map.getKeyPathValue(['no', 'sub', 1]), isNull);
      expect(map.getKeyPathValue(['test', 1, 'sub', 1]), isNull);
    });
  });
}
