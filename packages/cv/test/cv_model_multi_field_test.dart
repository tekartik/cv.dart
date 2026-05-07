// ignore_for_file: unused_import

import 'package:cv/cv.dart';
import 'package:cv/src/cv_model_mixin.dart';
import 'package:cv/src/dev_utils.dart';
import 'package:cv/src/env_utils.dart';
import 'package:test/test.dart';

export 'test_models.dart';

class _Test2 extends CvModelBase {
  final name = CvField<String>('name');

  @override
  CvFields get fields => [name];
}

class _Test1 extends CvModelBase {
  final test2 = CvMultiField2(
    CvModelField<_Test2>('test2'),
    CvField<String>('test2'),
  );

  @override
  CvFields get fields => [test2];
}

class _ListTest1 extends CvModelBase {
  final test2 = CvMultiListField2(
    CvModelListField<_Test2>('test2'),
    CvListField<String>('test2'),
  );

  @override
  CvFields get fields => [test2];
}

class _BadMultiFieldTest1 extends CvModelBase {
  final test2 = CvMultiField2(
    CvModelField<_Test2>('test2'),
    // ! wrong different name
    CvField<String>('test1'),
  );

  @override
  CvFields get fields => [test2];
}

void main() {
  cvAddConstructors([_Test1.new, _Test2.new, _ListTest1.new]);
  // debugContent = devWarning(true);
  group('model_multi_field', () {
    test('throws', () {
      if (isDebug) {
        expect(() => _BadMultiFieldTest1(), throwsArgumentError);
      }
    });
    test('string or type', () {
      var model = _Test1();
      model.fromMap({'test2': 'value'});
      expect(model.test2.field1.hasValue, isFalse);
      expect(model.test2.field2.hasValue, isTrue);
      expect(model.toMap(), {'test2': 'value'});

      model = _Test1();
      model.fromMap({
        'test2': {'name': 'value'},
      });
      expect(model.test2.field1.hasValue, isTrue);
      expect(model.test2.field2.hasValue, isFalse);
      expect(model.toMap(), {
        'test2': {'name': 'value'},
      });

      model.clear();
      model.test2.field1.v = _Test2()..name.v = 'value';
      expect(model.toMap(), {
        'test2': {'name': 'value'},
      });
      model.clear();
      model.test2.field2.v = 'value';
      expect(model.toMap(), {'test2': 'value'});
    });

    test('list string or type', () {
      var model = _ListTest1();
      expect(model.test2.hasValue, isFalse);
      expect(model.test2.multiList, isNull);
      model.fromMap({
        'test2': ['value'],
      });
      expect(model.test2.hasValue, isTrue);
      expect(model.test2.multiList, ['value']);
      expect(model.toMap(), {
        'test2': ['value'],
      });
      model.fromMap({
        'test2': [
          {'name': 'value'},
        ],
      });
      expect(model.test2.hasValue, isTrue);
      var multiList = model.test2.multiList!;
      expect(multiList, [_Test2()..name.v = 'value']);
      multiList.add('value');
      expect(model.toMap(), {
        'test2': [
          {'name': 'value'},
          'value',
        ],
      });
    });
  });
}
