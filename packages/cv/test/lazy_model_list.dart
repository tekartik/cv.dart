import 'package:cv/cv.dart';
import 'package:cv/src/cv_model_list.dart';
import 'package:test/test.dart';

import 'cv_model_test.dart';

void main() {
  cvAddConstructor(IntContent.new);

  group('model', () {
    test('lazy model list', () {
      var list = LazyModelList<IntContent>(mapList: <Model>[]);
      list.add(IntContent()..value.v = 1);
      list.add(IntContent()..value.v = 2);
      expect(list.toMapList(), [
        {'value': 1},
        {'value': 2},
      ]);
      expect(list.toMapList(), list.toMapList().cv<IntContent>().toMapList());
      expect(list.toMapList(), list.toMapList().cvType(IntContent).toMapList());
      list.removeAt(0);
      expect(list.toMapList(), [
        {'value': 2},
      ]);
    });
  });
}
