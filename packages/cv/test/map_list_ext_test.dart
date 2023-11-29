import 'package:cv/cv.dart';
import 'package:test/test.dart';

List<Map> get listWithOneEmptyModel => [{}];
void main() {
  group('Map/list ext', () {
    test('map_ext', () {
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

      expect(map.asModel(), isA<Model>());
    });
    test('list_ext', () {
      var list = [
        {
          'test': {
            'sub': ['a', 'b']
          }
        }
      ];
      expect(list.asModelList(), list);
      expect(list.asModelList(), isA<ModelList>());
    });
  });
}
