import 'dart:convert';

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
      expect(CvField<int>('name').hashCode, CvField<String>('name').hashCode);
      expect(
        (CvField<Object?>('name').v = 'test').hashCode,
        (CvField<Object?>('name').v = 'test').hashCode,
      );
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
        CvField<Object?>('name'),
        isNot(CvField<Object?>.withNull('name')),
      );
      expect(CvField('name', 1), CvField('name', 1));
      expect(CvField('name', [1]), CvField('name', [1]));
      expect(CvField('name', {'a': 'b'}), CvField('name', {'a': 'b'}));
      expect(CvField('name', 1), isNot(CvField('name', 2)));
      expect(CvField<Object?>('name'), isNot(CvField<Object?>('name2')));
      expect(CvField<Object?>('name'), isNot(CvField('name', 1)));
    });

    test('fromCvField', () {
      // set
      expect(
        CvField<String>('name')..fromCvField(CvField('name', 'value')),
        CvField('name', 'value'),
      );
      // erase
      expect(
        CvField<String>('name', 'value')..fromCvField(CvField('name')),
        CvField('name'),
      );
      // replace
      expect(
        CvField<String>('name', 'value')
          ..fromCvField(CvField('name', 'value2')),
        CvField('name', 'value2'),
      );
      // clear
      expect(
        CvField<String>('name', 'value')..fromCvField(CvField.withNull('name')),
        CvField.withNull('name'),
      );

      // bad type
      expect(
        CvField<int>('name', 1)..fromCvField(CvField('name', 'value')),
        CvField<Object?>.withNull('name'),
      );
    });

    test('fromCvFieldToString', () {
      expect(
        CvField<String>('name')..fromCvField(CvField('name', 12)),
        CvField('name', '12'),
      );
    });

    test('fromCvFieldBasicType', () {
      expect(
        CvField<int>('count')..fromCvField(CvField('count', '12')),
        CvField('count', 12),
      );
    });

    test('fillField', () {
      expect((CvField<int>('int')..fillField()).v, null);
      expect((CvField<int>('int')..fillField()).hasValue, true);
      expect(
        (CvField<int>('int')..fillField(CvFillOptions(valueStart: 0))).v,
        1,
      );
      expect(
        (CvField<String>('text')..fillField(CvFillOptions(valueStart: 0))).v,
        'text_1',
      );
      expect(
        (CvField<num>('num')..fillField(CvFillOptions(valueStart: 0))).v,
        1.5,
      );
      expect(
        (CvField<num>('double')..fillField(CvFillOptions(valueStart: 0))).v,
        1.5,
      );

      // List
      expect((CvField<List>('list')..fillField()).v, null);
      expect(
        (CvField<List>('list')..fillField(CvFillOptions(valueStart: 0))).v,
        isEmpty,
      );
      expect((CvField<List>('list')..fillField(cvFillOptions1)).v, [1]);
      expect(
        (CvField<List>('list')
          ..fillField(CvFillOptions(valueStart: 0, collectionSize: 2))).v,
        [1, 2],
      );
      // Map
      expect((CvField<Map>('map')..fillField()).v, null);
      expect(
        (CvField<Map>('map')..fillField(CvFillOptions(valueStart: 0))).v,
        isEmpty,
      );
      expect((CvField<Map>('map')..fillField(cvFillOptions1)).v, {
        'field_1': 1,
      });
      expect(
        (CvField<Map>('map')
          ..fillField(CvFillOptions(valueStart: 0, collectionSize: 2))).v,
        {'field_1': 1, 'field_2': 2},
      );
    });

    test('withName', () {
      var field = CvField<int>('test', 1);
      var newField = field.withName('newTest');
      expect(newField.name, 'newTest');
      expect(newField.value, 1);
    });

    test('encoded', () {
      var field = CvField.encoded<int, int>('test', codec: null);
      expect(field.value, isNull);
      expect(field.name, 'test');
      field.value = 1;
      expect(field.value, 1);
      field = CvField.encoded<int, String>('test', codec: IntToStringCodec());
      expect(field.value, isNull);
      expect(field.name, 'test');
      field.value = 1;
      expect(field.value, 1);
    });

    test('fillList', () {
      expect(
        (CvListField<int>('int')
          ..fillList(CvFillOptions(collectionSize: 1, valueStart: 0))).v,
        [1],
      );
    });

    test('fillModelMap', () {
      cvAddConstructor(IntContent.new);
      expect(
        (CvModelMapField<IntContent>('modelMap')
          ..fillMap(CvFillOptions(collectionSize: 1, valueStart: 0))).v,
        {'field_1': IntContent()..value.v = 1},
      );
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
        // ignore: avoid_print
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
    test('CvFields', () {
      var field1 = CvField<String>('name');
      var field2 = CvField<int>('count');
      [
        field1,
        field2,
      ].fromCvFields([CvField('other', 'test'), CvField('yet', 1)]);
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
    test('strict-inference ok', () {
      var field = CvField('test');
      expect(field.type.toString(), 'Object?');
    });
    test('CvFields.fromCvFields', () {
      var field1 = CvField<String>('name');
      var field2 = CvField<int>('count');
      [
        field1,
        field2,
      ].fromCvFields([CvField('other', 'test'), CvField('yet', 1)]);
      expect(field1.v, 'test');
      expect(field2.v, 1);
    });
    test('CvFields.matchingColumns', () {
      var field1 = CvField<String>('name');
      var field2 = CvField<int>('count');
      expect([field1, field2].matchingColumns(['count']), [field2]);
      expect([field1, field2].matchingColumns(null), [field1, field2]);
    });
    test('CvFields.columns', () {
      var field1 = CvField<String>('name');
      var field2 = CvField<int>('count');
      expect([field1, field2].columns, ['name', 'count']);
    });
    test('fromBasicTypeValue', () {
      var field = CvField<String>('name');
      field.fromBasicTypeValue(1);
      expect(field.v, '1');

      var intField = CvField<int>('count');
      intField.fromBasicTypeValue('1');
      expect(intField.v, 1);
      intField.fromBasicTypeValue('dummy', presentIfNull: false);
      expect(intField.v, 1);
      intField.fromBasicTypeValue('dummy', presentIfNull: true);
      expect(intField.v, 1);
    });
    test('int', () {
      var field = CvField<int>('int');
      field.fromBasicTypeValue(1.1);
      expect(field.v, 1);
      field.fromBasicTypeValue(2.9);
      expect(field.v, 3);
    });
    test('double', () {
      var field = CvField<double>('double');
      field.fromBasicTypeValue(1);
      expect(field.v, closeTo(1.0, 0.0001));
      field.fromBasicTypeValue(12345678912345678);
      expect(field.v, closeTo(12345678912345678, 0.00001));
    });
    test('num', () {
      var field = CvField<num>('num');
      field.fromBasicTypeValue(1);
      expect(field.v, isA<int>());
      expect(field.v, 1);
      field.fromBasicTypeValue(1.5);
      expect(field.v, isA<double>());
      expect(field.v, closeTo(1.5, 0.00001));
    });
  });
}

class IntToStringConverter with Converter<int, String> {
  const IntToStringConverter();
  @override
  String convert(int input) => input.toString();
}

class StringToIntConverter with Converter<String, int> {
  const StringToIntConverter();
  @override
  int convert(String input) => int.parse(input);
}

class IntToStringCodec with Codec<int, String> {
  @override
  Converter<String, int> get decoder => const StringToIntConverter();

  @override
  Converter<int, String> get encoder => const IntToStringConverter();
}
