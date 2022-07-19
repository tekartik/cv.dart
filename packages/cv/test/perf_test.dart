import 'package:cv/cv.dart';
import 'package:test/test.dart';

import 'cv_model_test.dart';

void main() {
  cvAddConstructor(AllTypes.new);
  group('perf', () {
    void perf(int count) {
      var mapList = List.generate(
          count,
          (index) => (AllTypes()
                ..fillModel(CvFillOptions(valueStart: 0, collectionSize: 1)))
              .toMap());
      var sw = Stopwatch()..start();
      mapList.cv<AllTypes>(lazy: false);
      print('count: $count');
      print('convert not lazy: ${sw.elapsed}');
      sw = Stopwatch()..start();
      mapList.cv<AllTypes>();
      print('convert lazy: ${sw.elapsed}');
    }

    test('perf100', () {
      perf(100);
    });
    test('perf100000', () {
      perf(100000);
    });
  });
}
