import 'package:cv/cv.dart';
import 'package:test/test.dart';

import 'cv_model_test.dart';

void main() {
  group('CvMapModel', () {
    test('field', () {
      var cv = CvMapModel();
      expect(cv.field('test'), isNull);
      cv['test'] = 1;
      expect(cv['test'], 1);
      expect(cv.field('test'), isNotNull);
      expect(cv.fields.first.v, 1);
    });
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
      expect(cv.toMap(), {});
      cv = CvMapModel()..copyFrom(IntContent()..value.vOrNull = null);
      expect(cv.toMap(), {'value': null});
      cv = CvMapModel()..copyFrom(IntContent()..value.v = 1);
      expect(cv.toMap(), {'value': 1});
    });
    test('toMap', () {
      var cv = CvMapModel();
      cv['test'] = 1;
      expect(cv.toMap(columns: ['test']), {'test': 1});
      expect(cv.toMap(columns: []), {});
    });
    test('child content toMap', () {
      var cv = CvMapModel();
      cv['test'] = ChildContent()..sub.v = 'sub_v';
      expect(cv.toMap(columns: ['test']), {
        'test': {'sub': 'sub_v'}
      });
      expect(cv.toMap(columns: []), {});
    });
    test('child content list toMap', () {
      var cv = CvMapModel();
      cv['test'] = [ChildContent()..sub.v = 'sub_v'];
      expect(cv.toMap(columns: ['test']), {
        'test': [
          {'sub': 'sub_v'}
        ]
      });
      expect(cv.toMap(columns: []), {});
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
      expect(cv.fields, []);
      cv['test'] = 1;
      expect(cv.fields, [CvField('test', 1)]);
      cv['test'] = null;
      expect(cv.fields, [CvField.withNull('test')]);
      expect(cv.toMap(), {'test': null});
      cv.field('test')!.v = 2;
      expect(cv.fields, [CvField('test', 2)]);
      expect(cv.toMap(), {'test': 2});
      cv.field('test')!.clear();
      expect(cv.fields, []);
      expect(cv.toMap(), {});

      cv = CvMapModel();
      cv['test'] = 1;
      expect(cv.fields, [CvField('test', 1)]);
      cv.clear();
      expect(cv.fields, []);
    });
  });
}
