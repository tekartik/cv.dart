import 'package:cv/cv.dart';
import 'package:test/test.dart';

import 'cv_model_test.dart';

void main() {
  group('CvField', () {
    test('cvValuesAreEquals', () {
      expect(cvValuesAreEqual(null, false), isFalse);
      expect(cvValuesAreEqual(null, null), isTrue);
      expect(cvValuesAreEqual(1, 1), isTrue);
      expect(cvValuesAreEqual(1, 2), isFalse);
      expect(cvValuesAreEqual(1, 'text'), isFalse);
      expect(cvValuesAreEqual([1], [1]), isTrue);
      expect(cvValuesAreEqual([1], [2]), isFalse);
      expect(cvValuesAreEqual({'a': 'b'}, {'a': 'b'}), isTrue);
    });
    test('hashCode', () {
      expect(CvField('name').hashCode, CvField('name').hashCode);
      expect((CvField('name').v = 'test').hashCode,
          (CvField('name').v = 'test').hashCode);
    });
    test('equals', () {
      expect(CvField('name'), CvField('name'));
      expect(CvField('name'), CvField('name', null));
      expect(CvField('name'), isNot(CvField.withValue('name', null)));
      expect(CvField('name'), isNot(CvField.withNull('name')));
      expect(CvField('name', 1), CvField('name', 1));
      expect(CvField('name', [1]), CvField('name', [1]));
      expect(CvField('name', {'a': 'b'}), CvField('name', {'a': 'b'}));
      expect(CvField('name', 1), isNot(CvField('name', 2)));
      expect(CvField('name'), isNot(CvField('name2')));
      expect(CvField('name'), isNot(CvField('name', 1)));
    });

    test('fromCvField', () {
      expect(CvField<String>('name')..fromCvField(CvField('name', 'value')),
          CvField('name', 'value'));
      // bad type
      expect(CvField<int>('name')..fromCvField(CvField('name', 'value')),
          CvField('name'));
    });

    test('fromCvFieldToString', () {
      expect(CvField<String>('name')..fromCvField(CvField('name', 12)),
          CvField('name', '12'));
    });

    test('nullable/non nullable', () {
      var field1 = CvField<int>('int');
      var field2 = CvField<int?>('int');
      expect(field1, field2);
      field1.setNull();
      field2.setNull();
      expect(field1.vOrNull, isNull);
      expect(field2.vOrNull, isNull);
      expect(field1, isNot(field2));
      expect(field1.hasValue, isFalse);
      expect(field2.hasValue, isTrue);
      try {
        // ignore: unused_local_variable, omit_local_variable_types
        int value = field1.v;
        fail('should fail');
      } on TypeError catch (e) {
        print(e.runtimeType);
      }
      field1.setValue(null, presentIfNull: true);
      field2.setValue(null, presentIfNull: true);
      expect(field1.hasValue, isFalse);
      expect(field2.hasValue, isTrue);
      expect(field1.vOrNull, isNull);
      expect(field2.vOrNull, isNull);
      field1.vOrNull = null;
      field2.vOrNull = null;
      expect(field1.hasValue, isFalse);
      expect(field2.hasValue, isTrue);
      expect(field1.vOrNull, isNull);
      expect(field2.vOrNull, isNull);
    });
    test('fillField', () {
      expect((CvField<int>('int')..fillField()).vOrNull, null);
      expect((CvField<int?>('int')..fillField()).hasValue, true);
      expect((CvField<int>('int')..fillField()).hasValue, false);
      expect(
          (CvField<int>('int')..fillField(CvFillOptions(valueStart: 0))).v, 1);
      expect(
          (CvField<String>('text')..fillField(CvFillOptions(valueStart: 0))).v,
          'text_1');
      expect((CvField<num>('num')..fillField(CvFillOptions(valueStart: 0))).v,
          1.5);
      expect(
          (CvField<num>('double')..fillField(CvFillOptions(valueStart: 0))).v,
          1.5);
    });

    test('withName', () {
      var field = CvField<int>('test', 1);
      var newField = field.withName('newTest');
      expect(newField.name, 'newTest');
      expect(newField.value, 1);
    });

    test('fillList', () {
      expect(
          (CvListField<int>('int')
                ..fillList(CvFillOptions(collectionSize: 1, valueStart: 0)))
              .v,
          [1]);
    });
    test('hasValue', () {
      var field = CvField('name');
      expect(field.hasValue, isFalse);
      expect(field.v, isNull);
      field.setNull();
      expect(field.hasValue, isTrue);
      expect(field.v, isNull);
      field.clear();
      expect(field.hasValue, isFalse);
      expect(field.v, isNull);
      field.v = 1;
      expect(field.v, 1);
      field.value = 2;
      expect(field.v, 2);
    });
    test('CvModelField', () {
      var modelField = CvModelField<IntContent>('test');
      cvAddBuilder<IntContent>((_) => IntContent());
      expect(modelField.create({}), const TypeMatcher<IntContent>());
    });
    test('withParent', () {
      var field = CvField('name').withParent('parent');
      expect(field.name, 'parent.name');
      var field2 = CvField('name').withParent('parent');
      expect(field, field2);
    });
    test('List<CvField>', () {
      var field1 = CvField<String>('name');
      var field2 = CvField<int>('count');
      [field1, field2]
          .fromCvFields([CvField('other', 'test'), CvField('yet', 1)]);
      expect(field1.v, 'test');
      expect(field2.v, 1);
    });
    test('toString()', () {
      var field = CvField('name');
      expect(field.toString(), 'name: null');
      field = CvField<int>('name', 1);
      expect(field.toString(), 'name: 1');
      field = CvField<int>.withNull('name');
      expect(field.toString(), 'name: null (set)');
    });
  });
}
