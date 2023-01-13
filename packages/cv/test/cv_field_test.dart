import 'package:cv/cv.dart';
import 'package:test/test.dart';

import 'cv_model_test.dart';

void main() {
  group('CvField', () {
    test('non inference ok', () {
      var field = CvField('test');
      expect(field.type.toString(), 'Object?');
    });
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
      expect(CvField<int>('name').hashCode, CvField<String>('name').hashCode);
      expect((CvField<Object?>('name').v = 'test').hashCode,
          (CvField<Object?>('name').v = 'test').hashCode);
    });
    test('withValue', () {
      expect(CvField<String>.withValue('name', null).v, isNull);
      expect(CvField<String>.withValue('name', null).name, 'name');
      expect(CvField<String>.withValue('name', 'test').v, 'test');
      expect(CvField<String>.withValue('name', null).hasValue, true);
    });
    test('equals', () {
      expect(CvField<Object?>('name'), CvField<Object?>('name'));
      expect(CvField<Object?>('name'), CvField('name', null));
      expect(CvField<Object?>('name'), isNot(CvField.withValue('name', null)));
      expect(
          CvField<Object?>('name'), isNot(CvField<Object?>.withNull('name')));
      expect(CvField('name', 1), CvField('name', 1));
      expect(CvField('name', [1]), CvField('name', [1]));
      expect(CvField('name', {'a': 'b'}), CvField('name', {'a': 'b'}));
      expect(CvField('name', 1), isNot(CvField('name', 2)));
      expect(CvField<Object?>('name'), isNot(CvField<Object?>('name2')));
      expect(CvField<Object?>('name'), isNot(CvField('name', 1)));
    });

    test('fromCvField', () {
      expect(CvField<String>('name')..fromCvField(CvField('name', 'value')),
          CvField('name', 'value'));
      // bad type
      expect(CvField<int>('name')..fromCvField(CvField('name', 'value')),
          CvField<Object?>('name'));
    });

    test('fromCvFieldToString', () {
      expect(CvField<String>('name')..fromCvField(CvField('name', 12)),
          CvField('name', '12'));
    });

    test('fillField', () {
      expect((CvField<int>('int')..fillField()).v, null);
      expect((CvField<int>('int')..fillField()).hasValue, true);
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

      // List
      expect((CvField<List>('list')..fillField()).v, null);
      expect((CvField<List>('list')..fillField(CvFillOptions(valueStart: 0))).v,
          isEmpty);
      expect(
          (CvField<List>('list')
                ..fillField(CvFillOptions(valueStart: 0, collectionSize: 1)))
              .v,
          [1]);
      expect(
          (CvField<List>('list')
                ..fillField(CvFillOptions(valueStart: 0, collectionSize: 2)))
              .v,
          [1, 2]);
      // Map
      expect((CvField<Map>('map')..fillField()).v, null);
      expect((CvField<Map>('map')..fillField(CvFillOptions(valueStart: 0))).v,
          isEmpty);
      expect(
          (CvField<Map>('map')
                ..fillField(CvFillOptions(valueStart: 0, collectionSize: 1)))
              .v,
          {'field_1': 1});
      expect(
          (CvField<Map>('map')
                ..fillField(CvFillOptions(valueStart: 0, collectionSize: 2)))
              .v,
          {'field_1': 1, 'field_2': 2});
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

    test('fillModelMap', () {
      cvAddConstructor(IntContent.new);
      expect(
          (CvModelMapField<IntContent>('modelMap')
                ..fillMap(CvFillOptions(collectionSize: 1, valueStart: 0)))
              .v,
          {'field_1': IntContent()..value.v = 1});
    });
    test('hasValue', () {
      var field = CvField<int>('name');
      expect(field.hasValue, isFalse);
      expect(field.v, isNull);
      expect(field.valueOrNull, isNull);
      try {
        field.valueOrThrow;
        fail('should fail');
      } on TypeError catch (e) {
        print(e.runtimeType);
      }
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
      field.valueOrThrow = 3;
      expect(field.v, 3);
      expect(field.isNull, isFalse);
      expect(field.isNotNull, isTrue);
      field.valueOrNull = null;
      expect(field.hasValue, isTrue);
      expect(field.v, isNull);
      expect(field.isNull, isTrue);
      expect(field.isNotNull, isFalse);
    });
    test('CvModelField', () {
      var modelField = CvModelField<IntContent>('test');
      cvAddBuilder<IntContent>((_) => IntContent());
      expect(modelField.create({}), const TypeMatcher<IntContent>());
    });
    test('CvModelMapField', () {
      var modelField = CvModelMapField<IntContent>('test');
      cvAddBuilder<IntContent>((_) => IntContent());
      expect(modelField.create({}), const TypeMatcher<IntContent>());
    });
    test('withParent', () {
      var field = CvField<Object?>('name').withParent('parent');
      expect(field.name, 'parent.name');
      var field2 = CvField<Object?>('name').withParent('parent');
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
      var field = CvField<Object?>('name');
      expect(field.toString(), 'name: <unset>');
      field = CvField<int>('name', 1);
      expect(field.toString(), 'name: 1');
      field = CvField<int>.withNull('name');
      expect(field.toString(), 'name: null');
    });
  });
}
