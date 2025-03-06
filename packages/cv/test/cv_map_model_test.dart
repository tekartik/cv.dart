import 'package:cv/cv.dart';
import 'package:cv/src/field.dart';
import 'package:test/test.dart';

import 'cv_model_test.dart';

class CvModelWithMapModel extends CvModelBase {
  final map = CvModelField<CvMapModel>('map');

  @override
  CvFields get fields => [map];
}

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
      src['test'] = 2;
      expect(cv.toMap(), {'test': 1});
      cv = CvMapModel()..copyFrom(IntContent());
      expect(cv.toMap(), isEmpty);
      cv = CvMapModel()..copyFrom(IntContent()..value.v = null);
      expect(cv.toMap(), {'value': null});
      cv = CvMapModel()..copyFrom(IntContent()..value.v = 1);
      expect(cv.toMap(), {'value': 1});

      // Undefined value
      cv = (CvMapModel()..['value'] = 1)..copyFrom(IntContent());
      expect(cv.toMap(), {'value': 1});
      // Null value
      cv =
          (CvMapModel()..['value'] = 1)..copyFrom(IntContent()..value.v = null);
      expect(cv.toMap(), {'value': null});
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
        'test': {'sub': 'sub_v'},
      });
      expect(cv.toMap(columns: []), isEmpty);
    });
    test('child content list toMap', () {
      var cv = CvMapModel();
      cv['test'] = [ChildContent()..sub.v = 'sub_v'];
      expect(cv.toMap(columns: ['test']), {
        'test': [
          {'sub': 'sub_v'},
        ],
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
      expect(cv.field('test'), isNull);
      cv['test'] = 1;
      expect(cv.field('test')!.v, 1);
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
      var field = cv.field('test')!;
      field.v = 2;
      expect(cv.toMap(), {'test': 2});
      cv.clear();
      expect(cv.fields, isEmpty);
    });

    test('auto_builder', () {
      cvAddConstructor(CvModelWithMapModel.new);
      var test = {'test': 1}.cv<CvMapModel>();
      expect(test.toMap(), {'test': 1});

      var model = CvModelWithMapModel()..map.v = test;
      var map = model.toMap();
      expect(map.cv<CvModelWithMapModel>().toMap(), {
        'map': {'test': 1},
      });
    });
    test('CvMapModelBase', () {
      var test = IntMapModelExtended();
      expect(test.fields, [test.value]);
      test.value.v = 1;
      //test['value'] = 1;
      expect(test.toMap(), {'value': 1});
      expect(test['value'], 1);
      test['value'] = 2;
      expect(test.toMap(), {'value': 2});
      expect(test.fields.names.toList(), ['value']);
      test['other'] = 3;
      expect(test.fields.names.toSet(), {'value', 'other'});
      expect(test['other'], 3);
      expect(test.toMap(), {'value': 2, 'other': 3});
      test.setValue('other', null, presentIfNull: true);
      expect(test.toMap(), {'value': 2, 'other': null});
      test.setValue('other', null, presentIfNull: false);
      expect(test.fields.names.toList(), ['value']);
      expect(test.toMap(), {'value': 2});

      test = IntMapModelExtended();
      test['value'] = 3;
      expect(test.value.v, 3);
      expect(test.fields.names.toSet(), {'value'});
      expect(test.toMap(), {'value': 3});

      test = IntMapModelExtended();
      test['other'] = 3;
      expect(test.toMap(), {'other': 3});
      expect(test.fields.names.toSet(), {'value', 'other'});
      expect(test['other'], 3);

      test = IntMapModelExtended()..fromMap({'value': 2, 'other': 3});
      expect(test.toMap(), {'value': 2, 'other': 3});
      expect(test.fields.names.toSet(), {'value', 'other'});

      test.clear();
      expect(test.toMap(), isEmpty);

      test = IntMapModelExtended();
      test['value'] = 3;
      test.remove('value');
      expect(test.toMap(), isEmpty);

      test = IntMapModelExtended();
      test['other'] = 3;
      test.remove('other');
      expect(test.toMap(), isEmpty);
    });
  });
}

class IntMapModelExtended extends CvMapModelBase {
  final value = CvField<int>('value');

  @override
  CvFields get modelFields => [value];
}
