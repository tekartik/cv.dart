import 'package:cv/cv.dart';
import 'package:test/test.dart';

import 'cv_model_test.dart';

void main() {
  group('CvMapModel', () {
    test('fromMap', () {
      var cv = CvMapModel();
      cv['test'] = 1;
      expect(cv.toMap(), {'test': 1});
      cv = CvMapModel()..fromMap({'test': 1});
      expect(cv.toMap(), {'test': 1});
      cv.fromMap({'test': 2});
      expect(cv.toMap(), {'test': 2});
    });
    test('copyFrom', () {
      var src = CvMapModel();
      src['test'] = 1;
      expect(src.toMap(), {'test': 1});
      var cv = CvMapModel()..copyFrom(src);
      expect(cv.toMap(), {'test': 1});
      cv = CvMapModel()..copyFrom(IntContent());
      expect(cv.toMap(), isEmpty);
      cv = CvMapModel()..copyFrom(IntContent()..value.v = null);
      expect(cv.toMap(), {'value': null});
      cv = CvMapModel()..copyFrom(IntContent()..value.v = 1);
      expect(cv.toMap(), {'value': 1});
    });
    test('toMap', () {
      var cv = CvMapModel();
      cv['test'] = 1;
      expect(cv.toMap(columns: ['test']), {'test': 1});
      expect(cv.toMap(columns: []), isEmpty);
    });
    test('child content toMap', () {
      var cv = CvMapModel();
      cv['test'] = ChildContent()..sub.v = 'sub_v';
      expect(cv.toMap(columns: ['test']), {
        'test': {'sub': 'sub_v'}
      });
      expect(cv.toMap(columns: []), isEmpty);
    });
    test('child content list toMap', () {
      var cv = CvMapModel();
      cv['test'] = [ChildContent()..sub.v = 'sub_v'];
      expect(cv.toMap(columns: ['test']), {
        'test': [
          {'sub': 'sub_v'}
        ]
      });
      expect(cv.toMap(columns: []), isEmpty);
    });
    test('withFields', () {
      var cv = CvMapModel.withFields([CvField('test', 1)]);
      expect(cv.toMap(), {'test': 1});
      cv['test2'] = 1;
      cv['test'] = 2;

      //expect(cv.toMap(), {'test': 1, 'test2': 1});
      expect(cv.toMap(), {'test': 2});
    });
    test('map', () {
      var cv = CvMapModel();
      expect(cv.fields, isEmpty);
      cv['test'] = 1;
      expect(cv.fields, [CvField('test', 1)]);
      cv['test'] = null;
      expect(cv.fields, [CvField<Object?>.withNull('test')]);
      expect(cv.toMap(), {'test': null});
      cv.field<Object?>('test')!.v = 2;
      expect(cv.fields, [CvField('test', 2)]);
      expect(cv.toMap(), {'test': 2});
      cv.field<Object?>('test')!.clear();
      expect(cv.fields, isEmpty);
      expect(cv.toMap(), isEmpty);

      cv = CvMapModel();
      cv['test'] = 1;
      expect(cv.fields, [CvField('test', 1)]);
      cv.clear();
      expect(cv.fields, isEmpty);
    });
  });
}
