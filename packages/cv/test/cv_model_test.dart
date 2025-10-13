// ignore_for_file: inference_failure_on_collection_literal

import 'dart:convert';

import 'package:cv/cv.dart';
// ignore: deprecated_member_use_from_same_package
import 'package:cv/src/cv_model_mixin.dart' show debugResetCvModelFieldChecks;
import 'package:test/test.dart';

import 'test_models.dart';
export 'test_models.dart';

CvFillOptions get testFillOptions => cvFillOptions1;

Model _fill<T extends CvModel>() =>
    (cvNewModel<T>()..fillModel(cvFillOptions1)).toMap();

void main() {
  group('cv', () {
    test('CvModel', () {
      var model = CvMapModel();
      model['test'] = 1;
    });
    test('equals', () {
      expect(IntContent(), IntContent());
      expect(IntContent()..value.v = 1, IntContent()..value.v = 1);
      expect(IntContent(), isNot(IntContent()..value.v = 1));
      expect(IntContent()..value.v = 2, isNot(IntContent()..value.v = 1));
    });
    test('toMap', () async {
      expect(IntContent().toMap(), isEmpty);
      expect(IntContent().toMap(includeMissingValue: true), {'value': null});
      expect((IntContent()..value.v = 1).toMap(), {'value': 1});
      expect((IntContent()..value.v = null).toMap(), {'value': null});
      expect((IntContent()..value.setValue(null)).toMap(), isEmpty);

      expect(
        (IntContent()..value.setValue(null, presentIfNull: true)).toMap(),
        {'value': null},
      );
      expect((IntContent()..value.v = 1).toMap(columns: <String>[]), isEmpty);
      expect(
        (IntContent()..value.v = 1).toMap(columns: <String>['other']),
        isEmpty,
      );
      expect(
        (IntContent()..value.v = 1).toMap(columns: [IntContent().value.k]),
        {'value': 1},
      );
      expect((IntContent()..field('value')!.v = 1).toMap(), {'value': 1});
      expect(IntContent().field('dummy'), isNull);
    });
    test('root fieldAtPath', () {
      var content = IntContent()..value.v = 1;
      var field = content.value;
      var list = [content];
      var rawList = <Object>[content];
      final map = {'map': content};
      final rawMap = Model.from(map);
      void check(String tag) {
        expect(content.fieldAtPath(['value']), field);
        expect(list.fieldAtPath([0, 'value']), field);
        expect(rawList.rawFieldAtPath([0, 'value']), field);
        expect(map.fieldAtPath(['map', 'value']), field, reason: tag);
        expect(rawMap.rawFieldAtPath(['map', 'value']), field, reason: tag);
      }

      check('set');
      field.setNull();
      check('null');
      field.clear();
      check('unset');
    });
    test('MapModel fieldAtPath', () {
      var field = CvField<int>('value', 1);
      var content = CvMapModel()..['value'] = 1;
      var list = [content];
      var rawList = <Object>[content];
      final map = {'map': content};
      final rawMap = Model.from(map);

      void check(String tag) {
        expect(content.fieldAtPath(['value']), field);
        expect(list.fieldAtPath([0, 'value']), field);
        expect(rawList.rawFieldAtPath([0, 'value']), field);
        expect(map.fieldAtPath(['map', 'value']), field, reason: tag);
        expect(rawMap.rawFieldAtPath(['map', 'value']), field, reason: tag);
      }

      check('set');

      field.v = null;
      content['value'] = null;
      check('null');

      field.clear();
      content.remove('value');
      expect(content.fieldAtPath(['value']), isNull);
      expect(list.fieldAtPath([0, 'value']), isNull);
      expect(rawList.rawFieldAtPath([0, 'value']), isNull);
    });
    test('Map fieldAtPath', () {
      var field = CvField<int>('value', 1);
      var map = <String, Object?>{'value': 1};

      var list = [map];
      var rawList = <Object>[map];
      expect(map.rawFieldAtPath(['value']), field);
      expect(list.rawFieldAtPath([0, 'value']), field);
      expect(rawList.rawFieldAtPath([0, 'value']), field);

      field.v = null;
      map['value'] = null;
      expect(map.rawFieldAtPath(['value']), field);
      expect(list.rawFieldAtPath([0, 'value']), field);
      expect(rawList.rawFieldAtPath([0, 'value']), field);

      field.clear();
      map.remove('value');
      expect(map.rawFieldAtPath(['value']), isNull);
      expect(list.rawFieldAtPath([0, 'value']), isNull);
      expect(rawList.rawFieldAtPath([0, 'value']), isNull);
    });
    test('ModelMap fieldAtPath', () {
      var model = WithChildMapCvField();
      var map = model.children.createMap();
      model.children.v = map;
      var child = ChildContent()..sub.v = '1';
      map['my_child'] = child;
      var field = child.sub;

      expect(model.fieldAtPath(['children', 'my_child', 'sub']), field);
      /*
      expect(list.fieldAtPath([0, 'value']), field);
      expect(rawList.fieldAtPath([0, 'value']), field);

      field.v = null;
      content['value'] = null;
      expect(content.fieldAtPath(['value']), field);
      expect(list.fieldAtPath([0, 'value']), field);
      expect(rawList.fieldAtPath([0, 'value']), field);

      field.clear();
      content.remove('value');
      expect(content.fieldAtPath(['value']), isNull);
      expect(list.fieldAtPath([0, 'value']), isNull);
      expect(rawList.fieldAtPath([0, 'value']), isNull);

       */
    });
    test('fromMap1', () async {
      var content = IntContent()..fromMap({});
      expect(content.value.hasValue, false);
      expect(content.value.v, null);
      content = IntContent()..fromMap({'value': null});
      expect(content.value.hasValue, true);
      expect(content.value.v, null);
      content = IntContent()..fromMap({'value': null});
      expect(content.value.hasValue, true);
      expect(content.value.v, null);

      // Bad type
      content = IntContent()..fromMap({'value': 'not an int'});
      expect(content.value.hasValue, false);
      expect(content.value.v, null);
      // Bad type, ok for string
      var stringContent = StringContent()..fromMap({'value': 12});
      expect(stringContent.value.hasValue, true);
      expect(stringContent.value.v, '12');

      cvAddConstructor(IntContent.new);
      content = newModel().cv<IntContent>();
      expect(content.value.hasValue, false);
      expect(content.value.v, null);
    });
    test('fromMap2', () async {
      expect(IntContent()..fromMap({}), IntContent());
      expect(IntContent()..fromMap({'value': 1}), IntContent()..value.v = 1);
      expect(
        IntContent()..fromMap({'value': 1}, columns: [IntContent().value.name]),
        IntContent()..value.v = 1,
      );
      expect(IntContent()..fromMap({'value': 1}, columns: []), IntContent());
      expect(
        IntContent()..fromMap({'value': 1}, columns: ['other']),
        IntContent(),
      );
    });
    test('copyFrom', () {
      var cv = IntContent()..copyFrom(IntContent());
      expect(cv.toMap(), isEmpty);
      cv = IntContent()..copyFrom(IntContent()..value.v = null);
      expect(cv.toMap(), {'value': null});
      cv = IntContent()..copyFrom(IntContent()..value.v = 1);
      expect(cv.toMap(), {'value': 1});

      var src = CvMapModel();
      src['value'] = 1;
      expect(src.toMap(), {'value': 1});
      cv = IntContent()..copyFrom(src);
      expect(cv.toMap(), {'value': 1});

      src = CvMapModel();
      src['test'] = 1;
      expect(src.toMap(), {'test': 1});
      cv = IntContent()..copyFrom(src);
      expect(cv.toMap(), isEmpty);

      var twoFields = TwoFieldsContent()
        ..value1.v = 1
        ..value2.v = 2;
      expect(TwoFieldsContent()..copyFrom(twoFields), twoFields);
      expect(
        TwoFieldsContent()..copyFrom(twoFields, columns: ['value1']),
        TwoFieldsContent()..value1.v = 1,
      );
      var twoFieldsMapModel = CvMapModel()..copyFrom(twoFields);
      expect(twoFieldsMapModel, twoFields);
      expect(
        (CvMapModel()..copyFrom(twoFields, columns: ['value1'])).toMap(),
        (TwoFieldsContent()..value1.v = 1).toMap(),
      );
      expect(
        (TwoFieldsContent()..copyFrom(twoFieldsMapModel, columns: ['value1']))
            .toMap(),
        (TwoFieldsContent()..value1.v = 1).toMap(),
      );

      // Undefined value
      cv = (IntContent()..value.v = 1)..copyFrom(IntContent());
      expect(cv.toMap(), {'value': 1});
      // Null value
      cv = (IntContent()..value.v = 1)..copyFrom(IntContent()..value.v = null);
      expect(cv.toMap(), {'value': null});
    });
    test('deep copyFrom', () {
      var child = ChildContent()..sub.v = '1';
      var cv = WithChildCvField()..child.v = child;
      var copy = WithChildCvField()..copyFrom(cv);
      child.sub.v = '2';
      expect(copy.toMap(), {
        'child': {'sub': '1'},
      });
    });
    test('Object.toMap', () async {
      var note = Note()
        ..title.v = 'my_title'
        ..content.v = 'my_content'
        ..date.v = 1;
      expect(note.toMap(), {
        'title': 'my_title',
        'content': 'my_content',
        'date': 1,
      });
      expect(note.toMap(columns: [note.title.name]), {'title': 'my_title'});
    });
    test('duplicated CvField', () {
      WithDuplicatedCvFields();

      try {
        WithDuplicatedCvFields().toMap();
        fail('should fail');
      } on CvBuilderException catch (_) {
        // print(e);
      }
      expect(WithDuplicatedCvFields().toMap(), isEmpty);
      WithDuplicatedCvFields().fromMap({});
      WithDuplicatedCvFields().copyFrom(CvMapModel());

      // ignore: deprecated_member_use_from_same_package
      debugResetCvModelFieldChecks();
      try {
        WithDuplicatedCvFields().toMap();
        fail('should fail');
      } on CvBuilderException catch (_) {
        // print(e);
      }

      // ignore: deprecated_member_use_from_same_package
      debugResetCvModelFieldChecks();
      try {
        WithDuplicatedCvFields().fromMap({});
        fail('should fail');
      } on CvBuilderException catch (_) {
        // print(e);
      }

      // ignore: deprecated_member_use_from_same_package
      debugResetCvModelFieldChecks();
      try {
        WithDuplicatedCvFields().copyFrom(CvMapModel());
        fail('should fail');
      } on CvBuilderException catch (_) {
        // print(e);
      }
    });
    test('content child', () {
      expect(WithChildCvField().toMap(), isEmpty);
      expect(WithChildCvField().toMap(includeMissingValue: true), {
        'child': null,
      });
      expect(
        (WithChildCvField()..child.v = ChildContent()).toMap(
          includeMissingValue: true,
        ),
        {
          'child': {'sub': null},
        },
      );
      var parent = WithChildCvField()
        ..child.v = (ChildContent()..sub.v = 'sub_value');
      var map = {
        'child': {'sub': 'sub_value'},
      };
      expect(parent.toMap(), map);
      parent = WithChildCvField()..fromMap(map);
      expect(parent.toMap(), map);
    });
    test('content child list', () {
      expect(WithChildListCvField().toMap(), isEmpty);
      expect(WithChildListCvField().toMap(includeMissingValue: true), {
        'children': null,
      });

      var parent = WithChildListCvField()
        ..children.v = [ChildContent()..sub.v = 'sub_value'];
      var map = {
        'children': [
          {'sub': 'sub_value'},
        ],
      };
      expect(parent.children.v!.first.sub.v, 'sub_value');
      expect(parent.toMap(), map);
      parent = WithChildListCvField()..fromMap(map);
      expect(parent.toMap(), map);
    });
    test('content child map', () {
      expect(WithChildMapCvField().toMap(), isEmpty);
      expect(WithChildMapCvField().toMap(includeMissingValue: true), {
        'children': null,
      });

      var parent = WithChildMapCvField()
        ..children.v = <String, ChildContent>{
          'key': ChildContent()..sub.v = 'sub_value',
        };
      var map = {
        'children': {
          'key': {'sub': 'sub_value'},
        },
      };
      expect(parent.children.v!.values.first.sub.v, 'sub_value');
      expect(parent.toMap(), map);
      parent = WithChildMapCvField()..fromMap(map);
      expect(parent.toMap(), map);
    });
    test('all types', () {
      AllTypes? allTypes;
      void doCheck() {
        var export = allTypes!.toMap();
        var import = AllTypes()..fromMap(export);
        expect(import, allTypes);
        expect(import.toMap(), allTypes.toMap());
        import = AllTypes()..fromMap(jsonDecode(jsonEncode(export)) as Map);

        expect(import.toMap(), allTypes.toMap());
      }

      allTypes = AllTypes();
      doCheck();
      allTypes
        ..intCvField.v = 1
        ..numCvField.v = 2.5
        ..stringCvField.v = 'some_test'
        ..intListCvField.v = [2, 3, 4]
        ..mapCvField.v = {'sub': 'map'}
        ..mapListCvField.v = [
          {'sub': 'map'},
        ]
        ..children.v = [
          WithChildCvField()..child.v = (ChildContent()..sub.v = 'sub_value'),
        ];
      doCheck();
    });

    test('basic type types', () {
      var allTypes = AllTypes();
      allTypes.intCvField.v = 1;
      expect(AllTypes()..fromMap({'int': 1}), allTypes);
      expect(AllTypes()..fromMap({'int': '1'}), allTypes);
    });

    test('builderCompat', () {
      expect(
        (CvModelField<IntContent>(
          'int',
          (_) => IntContent(),
        )..fillModel(CvFillOptions(valueStart: 0))).v,
        IntContent()..value.v = 1,
      );
    });
    test('recursive', () {
      cvAddConstructor(RecursiveContent.new);
      expect(_fill<RecursiveContent>(), {
        'value': 1,
        'recursive': {
          'value': 2,
          'recursive': {},
          'recursives': [{}],
          'recursiveMap': {'field_1': {}},
        },
        'recursives': [
          {
            'value': 3,
            'recursive': {},
            'recursives': [{}],
            'recursiveMap': {'field_1': {}},
          },
        ],
        'recursiveMap': {
          'field_1': {
            'value': 4,
            'recursive': {},
            'recursives': [{}],
            'recursiveMap': {'field_1': {}},
          },
        },
      });
    });

    test('basic fillModel', () {
      expect(
        (CvModelField<IntContent>.builder(
          'int',
          builder: (_) => IntContent(),
        )..fillModel(CvFillOptions(valueStart: 0))).v,
        IntContent()..value.v = 1,
      );
    });

    test('builderCompat', () {
      expect(
        (CvModelListField<IntContent>(
          'int',
          (_) => IntContent(),
        )..fillList(CvFillOptions(collectionSize: 1, valueStart: 0))).v,
        [IntContent()..value.v = 1],
      );
    });
    test('fillModelList', () {
      expect(
        (CvModelListField<IntContent>.builder(
          'int',
          builder: (_) => IntContent(),
        )..fillList(CvFillOptions(collectionSize: 1, valueStart: 0))).v,
        [IntContent()..value.v = 1],
      );
    });

    test('fillCvModel/fieldAtPath/valueAtPath', () {
      expect((IntContent()..fillModel(CvFillOptions(valueStart: 0))).toMap(), {
        'value': 1,
      });
      expect(
        (WithChildCvField()..fillModel(CvFillOptions(valueStart: 0))).toMap(),
        {
          'child': {'sub': 'text_1'},
        },
      );
      expect((WithChildListCvField()..fillModel(cvFillOptions1)).toMap(), {
        'children': [
          {'sub': 'text_1'},
        ],
      });
      var allTypes = AllTypes()..fillModel(cvFillOptions1);
      expect(allTypes.toMap(), {
        'bool': false,
        'int': 2,
        'num': 3.5,
        'double': 4,
        'string': 'text_5',
        'children': [
          {
            'child': {'sub': 'text_6'},
          },
        ],
        'intList': [7],
        'map': {'field_1': 8},
        'mapList': [
          {'field_1': 9},
        ],
        'stringList': ['text_10'],
        'list': [11],
        'modelMap': {
          'field_1': {
            'child': {'sub': 'text_12'},
          },
        },
        'model': {'field_1': 13},
        'modelList': [
          {'field_1': 14},
        ],
      });
      expect(allTypes.fieldAtPath(['int'])?.v, 2);
      expect(
        allTypes.fieldAtPath(['children', 0, 'child', 'sub'])?.v,
        'text_6',
      );
      expect(
        allTypes.fieldAtPath(['children', 0, 'child', 'sub'])?.v,
        'text_6',
      );
      expect(allTypes.valueAtPath(['children', 0, 'child', 'sub']), 'text_6');

      expect(
        allTypes.fieldAtPath(['children', 0, 'child'])?.v,
        isA<ChildContent>(),
      );
      expect(allTypes.valueAtPath(['children', 0, 'child']), {'sub': 'text_6'});

      expect(allTypes.fieldAtPath(['modelList']), isA<CvListField>());
      expect(allTypes.valueAtPath(['modelList']), [
        {'field_1': 14},
      ]);

      expect(allTypes.fieldAtPath(['children']), isA<CvModelListField>());
      expect(allTypes.valueAtPath(['children']), [
        {
          'child': {'sub': 'text_6'},
        },
      ]);

      expect(
        allTypes.fieldAtPath<int>(['children', 0, 'child', 'sub'])?.v,
        isNull,
      );
      expect(
        allTypes.valueAtPath<int>(['children', 0, 'child', 'sub']),
        isNull,
      );
      expect(
        allTypes.fieldAtPath<String>(['children', 0, 'child', 'sub'])?.v,
        'text_6',
      );
      expect(
        allTypes.valueAtPath<String>(['children', 0, 'child', 'sub']),
        'text_6',
      );

      expect(
        allTypes.fieldAtPath<String>(['children', 0, 'child', 'sub_no'])?.v,
        isNull,
      );
      expect(
        allTypes.fieldAtPath<String>(['children_no', 0, 'child', 'sub'])?.v,
        isNull,
      );
      expect(
        allTypes.fieldAtPath<String>(['children', 0, 1, 'sub'])?.v,
        isNull,
      );
      expect(
        allTypes.fieldAtPath<String>(['children', 'sub', 1, 'sub'])?.v,
        isNull,
      );
      // set
      expect(
        allTypes.valueAtPath<String>(['modelMap', 'field_1', 'child', 'sub']),
        'text_12',
      );
      allTypes.setValueAtPath([
        'modelMap',
        'field_1',
        'child',
        'sub',
      ], 'alt_text_12');
      expect(
        allTypes.valueAtPath<String>(['modelMap', 'field_1', 'child', 'sub']),
        'alt_text_12',
      );
      expect(
        allTypes.valueAtPath<String>(['children', 0, 'child', 'sub']),
        'text_6',
      );
      allTypes.setValueAtPath(['children', 0, 'child', 'sub'], 'alt_text_6');
      expect(
        allTypes.valueAtPath<String>(['children', 0, 'child', 'sub']),
        'alt_text_6',
      );
      expect(
        (CustomContent()..fillModel(
              CvFillOptions(
                valueStart: 0,
                collectionSize: 1,
                generate: (type, options) {
                  if (type == Custom) {
                    if (options.valueStart != null) {
                      var value = options.valueStart = options.valueStart! + 1;
                      return Custom('custom_$value');
                    }
                  }
                  return null;
                },
              ),
            ))
            .toMap(),
        {
          'custom1': Custom('custom_1'),
          'custom2': Custom('custom_2'),
          'text': 'text_3',
        },
      );
    });
    test('custom', () {
      expect((CustomContent()..custom1.v = Custom('test')).toMap(), {
        'custom1': Custom('test'),
      });
    });
    test('CvFieldWithParent', () {
      var object = WithCvFieldWithParent();
      expect(object.fields.map((e) => e.name), ['sub.value', 'sub.value2']);
      expect((WithCvFieldWithParent()..value.v = 1).toMap(), {
        'sub': {'value': 1},
      });
      expect(
        (WithCvFieldWithParent()
              ..value.v = 1
              ..value2.v = 2)
            .toMap(),
        {
          'sub': {'value': 1, 'value2': 2},
        },
      );
      expect((WithCvFieldWithParent()..value.v = null).toMap(), {
        'sub': {'value': null},
      });
      expect(WithCvFieldWithParent().toMap(), isEmpty);

      object = WithCvFieldWithParent()
        ..fromMap({
          'sub': {'value': 1},
        });
      expect(object.value.v, 1);
      expect(object.toMap(), {
        'sub': {'value': 1},
      });

      expect((WithCvFieldWithParent()..fillModel(cvFillOptions1)).toMap(), {
        'sub': {'value': 1, 'value2': 2},
      });

      expect(
        WithCvFieldWithParent()..value.v = 1,
        WithCvFieldWithParent()..value.v = 1,
      );
      expect(
        (WithCvFieldWithParent()..value.v = 1).hashCode,
        (WithCvFieldWithParent()..value.v = 1).hashCode,
      );

      // Missing map
      object = WithCvFieldWithParent()..fromMap({'dummy': 1});
      expect(object.value.v, null);
      expect(object.toMap(), isEmpty);

      // Not a map
      object = WithCvFieldWithParent()..fromMap({'sub': 1});
      expect(object.value.v, null);
      expect(object.toMap(), isEmpty);
    });
    test('CvModelFieldWithParent', () {
      var map = {
        'sub': {
          'value': {'value': 1},
        },
      };
      var model = WithCvModelFieldWithParent()
        ..value.v = (IntContent()..value.v = 1);
      expect(model.toMap(), map);
      model = WithCvModelFieldWithParent()..fromMap(map);
      expect(model.toMap(), map);
    });
    test('auto children', () {
      cvAddBuilder<ChildContent>((_) => ChildContent());

      expect((WithAutoChildren()..fillModel(testFillOptions)).toMap(), {
        'child': {'sub': 'text_1'},
        'children': [
          {'sub': 'text_2'},
        ],
      });
    });
    test('updated fields', () {
      var model = WithUpdateFields()..test1.v = 1;
      expect(model.toMap(), {'test1': 1});
      model.test2 = CvField<int>('test2', 2);
      expect(model.toMap(), {'test1': 1, 'test2': 2});
    });
    test('strict-inference ok', () {
      var model = CvMapModel();
      // No warning
      model.field('test');
    });
    test('encoded', () {
      var model = WithEncodedFields();
      expect(model.toMap(), isEmpty);
      model.test.v = 1;
      expect(model.test.v, 1);
      expect(model.toMap(), {'test': '1'});
      model.fromMap({'test': '2'});
      expect(model.toMap(), {'test': '2'});
      expect(model.test.v, 2);
    });
    test('encoded Enum', () {
      var model = EnumContent();
      expect(model.toMap(), isEmpty);
      model.value.v = ExampleEnum.one;
      expect(model.value.v, ExampleEnum.one);
      expect(model.toMap(), {'value': 'one'});
      model.fromMap({'value': 'two'});
      expect(model.toMap(), {'value': 'two'});
      expect(model.value.v, ExampleEnum.two);
      // not valid, ignored
      model.fromMap({'value': 'dummy'});
      expect(model.value.v, ExampleEnum.two);
    });
    test('encoded with dependency', () {
      var model = WithDependentEncodedFields();
      expect(model.toMap(), isEmpty);
      model.test.v = '1';
      expect(model.test.v, '1');
      expect(model.toMap(), {'test': ',1'});
      model.fromMap({'test': ',2'}); // fail!
      expect(model.toMap(), {'test': ',1'});
      model.dep.v = 'pre';
      model.fromMap({'test': 'pre,2'}); // fail!
      expect(model.test.v, '2');
      expect(model.toMap(), {'dep': 'pre', 'test': 'pre,2'});
    });
    test('cvModelAreEquals', () {
      var content1 = TwoFieldsContent()
        ..value1.v = 1
        ..value2.v = 2;
      var content2 = TwoFieldsContent()
        ..value1.v = 1
        ..value2.v = 2;
      expect(cvModelsAreEquals(content1, content2), true);
      content1.value1.v = 3;
      expect(cvModelsAreEquals(content1, content2), false);
      expect(
        cvModelsAreEquals(content1, content2, columns: [content1.value1.key]),
        false,
      );
      expect(
        cvModelsAreEquals(content1, content2, columns: [content1.value2.key]),
        true,
      );
      expect(
        cvModelsAreEquals(
          content1,
          content2,
          columns: [content1.value1.key, content1.value2.key],
        ),
        false,
      );
    });
    test('cvModelAreEquals', () {
      expect(CvModelEmpty().toMap(), isEmpty);
    });
    test('cvNewModel', () {
      cvAddConstructor(IntContent.new);
      var model = cvNewModel<IntContent>();
      var model2 = cvTypeNewModel(IntContent);
      expect(model2, model);
      expect(model2, isA<IntContent>());
      var model3 = cvTypeNewModel<CvModel>(IntContent);
      expect(model3, isA<IntContent>());
    });
    test('cvClone', () {
      cvAddConstructor(IntContent.new);
      var model = cvNewModel<IntContent>();
      var model2 = model.clone();
      expect(model2, model);
      expect(model2, isA<IntContent>());
    });
    test('clone sub class', () {
      cvAddConstructor(CloneBaseClass.new);
      cvAddConstructor(CloneBaseClass1.new);
      CloneBaseClass base = CloneBaseClass1();
      var clone = base.clone();
      expect(clone, isNot(isA<CloneBaseClass1>()));
      expect(clone, isA<CloneBaseClass>());
    });
    test('clone sub class abstract', () {
      cvAddConstructor(NonAbstractSubClass1.new);
      cvAddBuilder(AbstractCloneBaseClass.builder);
      var base = cvNewModel<AbstractCloneBaseClass>();
      var clone = base.clone();
      expect(clone, isA<NonAbstractSubClass1>());
      var class1 = NonAbstractSubClass1();
      var clone1 = class1.clone();
      expect(clone1, isA<NonAbstractSubClass1>());
      base = NonAbstractSubClass2();
      var clone2 = base.clone();
      expect(clone2, isA<NonAbstractSubClass1>());
      base = NonAbstractSubClass2()
        ..type.v = 2
        ..other.v = 123;
      var clone3 = base.clone();
      expect(clone3, isA<NonAbstractSubClass2>());
      expect(clone3.other.v, 123);
    });
    test('basic list', () {
      var model = AllTypes();
      model.fromMap({
        'intList': [1, 2.1, '3.1'],
        'stringList': [4, '5', true],
      });
      expect(model.intListCvField.v, [1, 2, 3]);
      expect(model.stringListCvField.v, ['4', '5', 'true']);
    });

    test('fillModel missing builder', () {
      cvAddConstructor(TestInnerWithoutBuilder.new);
      try {
        expect(
          (newModel().cv<TestInnerWithoutBuilder>()..fillModel(testFillOptions))
              .toMap(),
          isEmpty,
        );
        fail('should fail');
      } on CvBuilderException catch (e) {
        //print(e.runtimeType);
        //print(e);
        // Missing builder for NoBuilderIntContent, call addBuilder
        expect(e.toString().toLowerCase(), contains('missing builder'));
        expect(e.toString(), contains('NoBuilderIntContent'));
      }
    });

    test('setAtFieldPath', () {
      var content = AllTypes();
      content.setValueAtFieldPath(CvFieldPath([content.intCvField.k]), 1);
      expect(content.intCvField.v, 1);
      content.intListCvField.v = [2];
      expect(
        content.valueAtFieldPath(CvFieldPath([content.intListCvField.k, 0])),
        2,
      );
      content.setValueAtFieldPath(
        CvFieldPath([content.intListCvField.k, 0]),
        3,
      );
      expect(content.intListCvField.v, [3]);
    });
  });
}
