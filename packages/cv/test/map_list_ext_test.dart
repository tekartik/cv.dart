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
    test('Map.deepClose', () {
      var sub = [1];
      var map = {'sub': sub};
      var newMap = map.deepClone();
      expect(newMap, map);
      expect(newMap, isNot(same(map)));
      expect(newMap['sub'], isNot(same(sub)));
    });
    test('List.deepClose', () {
      var sub = {'sub': 1};
      var list = [sub];
      var newList = list.deepClone();
      expect(newList, list);
      expect(newList, isNot(same(list)));
      expect(newList[0], isNot(same(sub)));
    });
    test('Complex.deepClose', () {
      var sub1 = {'sub': 1};
      var sub2 = [2];
      var complex = {
        'sub1': {
          'sub2': {
            'list1': [
              [
                [sub1, sub2]
              ]
            ]
          }
        },
        'sub3': sub1
      };

      var newMap = complex.deepClone();
      expect(newMap, complex);
      var newSub1 = newMap.getKeyPathValue(['sub1', 'sub2', 'list1', 0, 0, 0]);
      var oldSub1 = complex.getKeyPathValue(['sub1', 'sub2', 'list1', 0, 0, 0]);

      expect(newSub1, sub1);
      expect(oldSub1, sub1);
      expect(newSub1, isNot(same(sub1)));
      expect(oldSub1, same(sub1));
    });
    test('keyPartsToString', () {
      expect(keyPartsToString(['test', 1, 'sub', 2]), 'test.1.sub.2');
      expect(keyPartsToString(['test', '1', 'sub', 2]), 'test."1".sub.2');
    });
    test('keyPartsFromString', () {
      expect(keyPartsFromString('test.1.sub.2'), ['test', 1, 'sub', 2]);
      expect(
        keyPartsFromString('test."1".sub.2'),
        ['test', '1', 'sub', 2],
      );
    });
  });
}
