import 'package:cv/cv.dart';
import 'package:test/test.dart';

class _Test2 extends CvModelBase {
  final name = CvField<String>('name');

  @override
  CvFields get fields => [name];
}

void main() {
  cvAddConstructors([_Test2.new]);
  group('cv_multi_field', () {
    test('int or string', () {
      var field = CvMultiField2(CvField<String>('any'), CvField<int>('any'));
      expect(field.hasValue, isFalse);
      expect(field.multiField, isNull);
      expect(field.multiValue, isNull);
      field.multiFromAnyValue(2);
      expect(field.hasValue, isTrue);
      expect(field.field1.hasValue, isFalse);
      expect(field.field2.v, 2);
      expect(field.multiField, isA<CvField<int>>());
      expect(field.multiValue, 2);

      field.multiFromAnyValue('1');
      expect(field.field2.v, 2);
      expect(field.field1.v, '1');

      field.clear();
      expect(field.hasValue, isFalse);
      field.multiFromAnyValue('1');
      expect(field.hasValue, isTrue);
      expect(field.field2.hasValue, isFalse);
      expect(field.field1.v, '1');

      field.clear();

      expect((field..fillField(cvFillOptions1)).multiValue, 'text_1');
    });
    test('list or map', () {
      var field = CvMultiField2(
        CvModelField<_Test2>('any'),
        CvModelListField<_Test2>('any'),
      );
      field.multiFromAnyValue({'name': 'value'});

      expect(field.field1.value!.name.v, 'value');
      field.multiFromAnyValue([
        {'name': 'value'},
      ]);

      expect(field.field2.value!.first.name.v, 'value');

      expect(
        (field..fillField(cvFillOptions1)).multiValue,
        (_Test2())..name.v = 'text_1',
      );
    });
    test('list of map or string', () {
      var field = CvMultiListField2(
        CvModelListField<_Test2>('any'),
        CvListField<String>('any'),
      );
      expect(field.hasValue, isFalse);
      field.multiFromAnyList([
        {'name': 'value'},
        'value2',
      ]);
      expect(field.hasValue, isTrue);
      expect(field.multiList, [(_Test2()..name.v = 'value'), 'value2']);
      field.multiList!.add('test');
      expect(field.multiList, [_Test2()..name.v = 'value', 'value2', 'test']);
      field.multiList = ['test'];
      expect(field.multiList, ['test']);
      expect(() => field.value, throwsStateError);

      expect(
        (field..fillField(cvFillOptions1.copyWith(collectionSize: 2)))
            .multiList,
        [_Test2()..name.v = 'text_1', _Test2()..name.v = 'text_2'],
      );
    });
  });
}
