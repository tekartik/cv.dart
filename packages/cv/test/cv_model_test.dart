import 'dart:convert';

import 'package:cv/cv.dart';
import 'package:cv/src/builder.dart';
import 'package:cv/src/cv_model_mixin.dart';
import 'package:test/test.dart';

import 'cv_field_test.dart';

CvFillOptions get testFillOptions =>
    CvFillOptions(valueStart: 0, collectionSize: 1);

class Note extends CvModelBase {
  final title = CvField<String>('title');
  final content = CvField<String>('content');
  final date = CvField<int>('date');

  @override
  CvFields get fields => [title, content, date];
}

class IntContent extends CvModelBase {
  final value = CvField<int>('value');

  @override
  CvFields get fields => [value];
}

class TwoFieldsContent extends CvModelBase {
  final value1 = CvField<int>('value1');
  final value2 = CvField<int>('value2');

  @override
  CvFields get fields => [value1, value2];
}

/// Builder
IntContent intContentBuilder(Map map) => IntContent();

/// This builder is never added, except locally
class NoBuilderIntContent extends CvModelBase {
  final value = CvField<int>('value');

  @override
  CvFields get fields => [value];
}

class TestInnerWithoutBuilder extends CvModelBase {
  final inner = CvModelField<NoBuilderIntContent>('inner');
  @override
  CvFields get fields => [inner];
}

void addNoBuilderIntContentBuilder() {
  cvAddBuilder(noBuilderIntContentBuilder);
}

void removeNoBuilderIntContentBuilder() {
  cvRemoveBuilder(NoBuilderIntContent);
}

/// Builder to add and remove
NoBuilderIntContent noBuilderIntContentBuilder(Map map) =>
    NoBuilderIntContent();

class Custom {
  final String value;

  Custom(this.value);

  @override
  String toString() => value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Custom && (other.value == value);
  }
}

class CustomContent extends CvModelBase {
  final custom1 = CvField<Custom>('custom1');
  final custom2 = CvField<Custom>('custom2');
  final text = CvField<String>('text');

  @override
  CvFields get fields => [
        custom1,
        custom2,
        text,
      ];
}

class StringContent extends CvModelBase {
  final value = CvField<String>('value');

  @override
  CvFields get fields => [value];
}

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

      expect((IntContent()..value.setValue(null, presentIfNull: true)).toMap(),
          {'value': null});
      expect((IntContent()..value.v = 1).toMap(columns: <String>[]), isEmpty);
      expect((IntContent()..value.v = 1).toMap(columns: <String>['other']),
          isEmpty);
      expect((IntContent()..value.v = 1).toMap(columns: [IntContent().value.k]),
          {'value': 1});
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
    });
    test('fromMap2', () async {
      expect(IntContent()..fromMap({}), IntContent());
      expect(IntContent()..fromMap({'value': 1}), IntContent()..value.v = 1);
      expect(
          IntContent()
            ..fromMap({'value': 1}, columns: [IntContent().value.name]),
          IntContent()..value.v = 1);
      expect(IntContent()..fromMap({'value': 1}, columns: []), IntContent());
      expect(IntContent()..fromMap({'value': 1}, columns: ['other']),
          IntContent());
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
      expect(TwoFieldsContent()..copyFrom(twoFields, columns: ['value1']),
          TwoFieldsContent()..value1.v = 1);
      var twoFieldsMapModel = CvMapModel()..copyFrom(twoFields);
      expect(twoFieldsMapModel, twoFields);
      expect((CvMapModel()..copyFrom(twoFields, columns: ['value1'])).toMap(),
          (TwoFieldsContent()..value1.v = 1).toMap());
      expect(
          (TwoFieldsContent()..copyFrom(twoFieldsMapModel, columns: ['value1']))
              .toMap(),
          (TwoFieldsContent()..value1.v = 1).toMap());
    });
    test('toMap', () async {
      var note = Note()
        ..title.v = 'my_title'
        ..content.v = 'my_content'
        ..date.v = 1;
      expect(note.toMap(),
          {'title': 'my_title', 'content': 'my_content', 'date': 1});
      expect(note.toMap(columns: [note.title.name]), {'title': 'my_title'});
    });
    test('duplicated CvField', () {
      WithDuplicatedCvFields();

      try {
        WithDuplicatedCvFields().toMap();
        fail('should fail');
      } on CvBuilderException catch (e) {
        print(e);
      }
      expect(WithDuplicatedCvFields().toMap(), isEmpty);
      WithDuplicatedCvFields().fromMap({});
      WithDuplicatedCvFields().copyFrom(CvMapModel());

      // ignore: deprecated_member_use_from_same_package
      debugResetCvModelFieldChecks();
      try {
        WithDuplicatedCvFields().toMap();
        fail('should fail');
      } on CvBuilderException catch (e) {
        print(e);
      }

      // ignore: deprecated_member_use_from_same_package
      debugResetCvModelFieldChecks();
      try {
        WithDuplicatedCvFields().fromMap({});
        fail('should fail');
      } on CvBuilderException catch (e) {
        print(e);
      }

      // ignore: deprecated_member_use_from_same_package
      debugResetCvModelFieldChecks();
      try {
        WithDuplicatedCvFields().copyFrom(CvMapModel());
        fail('should fail');
      } on CvBuilderException catch (e) {
        print(e);
      }
    });
    test('content child', () {
      expect(WithChildCvField().toMap(), isEmpty);
      expect(
          WithChildCvField().toMap(includeMissingValue: true), {'child': null});
      expect(
          (WithChildCvField()..child.v = ChildContent())
              .toMap(includeMissingValue: true),
          {
            'child': {'sub': null}
          });
      var parent = WithChildCvField()
        ..child.v = (ChildContent()..sub.v = 'sub_value');
      var map = {
        'child': {'sub': 'sub_value'}
      };
      expect(parent.toMap(), map);
      parent = WithChildCvField()..fromMap(map);
      expect(parent.toMap(), map);
    });
    test('content child list', () {
      expect(WithChildListCvField().toMap(), isEmpty);
      expect(WithChildListCvField().toMap(includeMissingValue: true),
          {'children': null});

      var parent = WithChildListCvField()
        ..children.v = [ChildContent()..sub.v = 'sub_value'];
      var map = {
        'children': [
          {'sub': 'sub_value'}
        ]
      };
      expect(parent.children.v!.first.sub.v, 'sub_value');
      expect(parent.toMap(), map);
      parent = WithChildListCvField()..fromMap(map);
      expect(parent.toMap(), map);
    });
    test('content child map', () {
      expect(WithChildMapCvField().toMap(), isEmpty);
      expect(WithChildMapCvField().toMap(includeMissingValue: true),
          {'children': null});

      var parent = WithChildMapCvField()
        ..children.v = <String, ChildContent>{
          'key': ChildContent()..sub.v = 'sub_value'
        };
      var map = {
        'children': {
          'key': {'sub': 'sub_value'}
        }
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
          {'sub': 'map'}
        ]
        ..children.v = [
          WithChildCvField()..child.v = (ChildContent()..sub.v = 'sub_value')
        ];
      doCheck();
    });

    test('builderCompat', () {
      expect(
          (CvModelField<IntContent>('int', (_) => IntContent())
                ..fillModel(CvFillOptions(valueStart: 0)))
              .v,
          IntContent()..value.v = 1);
    });

    test('basic fillModel', () {
      expect(
          (CvModelField<IntContent>.builder('int', builder: (_) => IntContent())
                ..fillModel(CvFillOptions(valueStart: 0)))
              .v,
          IntContent()..value.v = 1);
    });

    test('builderCompat', () {
      expect(
          (CvModelListField<IntContent>('int', (_) => IntContent())
                ..fillList(CvFillOptions(collectionSize: 1, valueStart: 0)))
              .v,
          [IntContent()..value.v = 1]);
    });
    test('fillModelList', () {
      expect(
          (CvModelListField<IntContent>.builder('int',
                  builder: (_) => IntContent())
                ..fillList(CvFillOptions(collectionSize: 1, valueStart: 0)))
              .v,
          [IntContent()..value.v = 1]);
    });

    test('fillCvModel', () {
      expect((IntContent()..fillModel(CvFillOptions(valueStart: 0))).toMap(),
          {'value': 1});
      expect(
          (WithChildCvField()..fillModel(CvFillOptions(valueStart: 0))).toMap(),
          {
            'child': {'sub': 'text_1'}
          });
      expect(
          (WithChildListCvField()
                ..fillModel(CvFillOptions(valueStart: 0, collectionSize: 1)))
              .toMap(),
          {
            'children': [
              {'sub': 'text_1'}
            ]
          });
      var allTypes = AllTypes()
        ..fillModel(CvFillOptions(valueStart: 0, collectionSize: 1));
      expect(allTypes.toMap(), {
        'bool': false,
        'int': 2,
        'num': 3.5,
        'string': 'text_4',
        'children': [
          {
            'child': {'sub': 'text_5'}
          }
        ],
        'intList': [6],
        'map': {'field_1': 7},
        'mapList': [
          {'field_1': 8}
        ],
        'stringList': ['text_9'],
        'list': [10],
        'modelMap': {
          'field_1': {
            'child': {'sub': 'text_11'}
          }
        },
        'model': {'field_1': 12},
        'modelList': [
          {'field_1': 13}
        ]
      });
      expect(
          allTypes.fieldAtPath(['children', 0, 'child', 'sub'])?.v, 'text_5');
      expect(allTypes.fieldAtPath<int>(['children', 0, 'child', 'sub'])?.v,
          isNull);
      expect(allTypes.fieldAtPath<String>(['children', 0, 'child', 'sub'])?.v,
          'text_5');
      expect(
          allTypes.fieldAtPath<String>(['children', 0, 'child', 'sub_no'])?.v,
          isNull);
      expect(
          allTypes.fieldAtPath<String>(['children_no', 0, 'child', 'sub'])?.v,
          isNull);
      expect(
          allTypes.fieldAtPath<String>(['children', 0, 1, 'sub'])?.v, isNull);
      expect(allTypes.fieldAtPath<String>(['children', 'sub', 1, 'sub'])?.v,
          isNull);
      expect(
          (CustomContent()
                ..fillModel(CvFillOptions(
                    valueStart: 0,
                    collectionSize: 1,
                    generate: (type, options) {
                      if (type == Custom) {
                        if (options.valueStart != null) {
                          var value =
                              options.valueStart = options.valueStart! + 1;
                          return Custom('custom_$value');
                        }
                      }
                      return null;
                    })))
              .toMap(),
          {
            'custom1': Custom('custom_1'),
            'custom2': Custom('custom_2'),
            'text': 'text_3'
          });
    });
    test('custom', () {
      expect((CustomContent()..custom1.v = Custom('test')).toMap(),
          {'custom1': Custom('test')});
    });
    test('CvFieldWithParent', () {
      var object = WithCvFieldWithParent();
      expect(object.fields.map((e) => e.name), ['sub.value', 'sub.value2']);
      expect((WithCvFieldWithParent()..value.v = 1).toMap(), {
        'sub': {'value': 1}
      });
      expect(
          (WithCvFieldWithParent()
                ..value.v = 1
                ..value2.v = 2)
              .toMap(),
          {
            'sub': {'value': 1, 'value2': 2}
          });
      expect((WithCvFieldWithParent()..value.v = null).toMap(), {
        'sub': {'value': null}
      });
      expect(WithCvFieldWithParent().toMap(), isEmpty);

      object = WithCvFieldWithParent()
        ..fromMap({
          'sub': {'value': 1}
        });
      expect(object.value.v, 1);
      expect(object.toMap(), {
        'sub': {'value': 1}
      });

      expect(
          (WithCvFieldWithParent()
                ..fillModel(CvFillOptions(valueStart: 0, collectionSize: 1)))
              .toMap(),
          {
            'sub': {'value': 1, 'value2': 2}
          });

      expect(WithCvFieldWithParent()..value.v = 1,
          WithCvFieldWithParent()..value.v = 1);
      expect((WithCvFieldWithParent()..value.v = 1).hashCode,
          (WithCvFieldWithParent()..value.v = 1).hashCode);

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
          'value': {'value': 1}
        }
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
          {'sub': 'text_2'}
        ]
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
          false);
      expect(
          cvModelsAreEquals(content1, content2, columns: [content1.value2.key]),
          true);
      expect(
          cvModelsAreEquals(content1, content2,
              columns: [content1.value1.key, content1.value2.key]),
          false);
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
    });
    test('fillModel missing builder', () {
      cvAddConstructor(TestInnerWithoutBuilder.new);
      try {
        expect(
            (newModel().cv<TestInnerWithoutBuilder>()
                  ..fillModel(testFillOptions))
                .toMap(),
            isEmpty);
        fail('should fail');
      } on CvBuilderException catch (e) {
        //print(e.runtimeType);
        //print(e);
        // Missing builder for NoBuilderIntContent, call addBuilder
        expect(e.toString().toLowerCase(), contains('missing builder'));
        expect(e.toString(), contains('NoBuilderIntContent'));
      }
    });
  });
}

class WithDuplicatedCvFields extends CvModelBase {
  final cvField1 = CvField<String>('CvField1');
  final cvField2 = CvField<String>('CvField1');

  @override
  CvFields get fields => [cvField1, cvField2];
}

class WithChildCvField extends CvModelBase {
  final child = CvModelField<ChildContent>.builder('child',
      builder: (_) => ChildContent());

  @override
  CvFields get fields => [child];
}

class WithChildListCvField extends CvModelBase {
  final children = CvModelListField<ChildContent>.builder('children',
      builder: (_) => ChildContent());

  @override
  CvFields get fields => [children];
}

class WithChildMapCvField extends CvModelBase {
  final children = CvModelMapField<ChildContent>.builder('children',
      builder: (_) => ChildContent());

  @override
  CvFields get fields => [children];
}

class WithCvFieldWithParent extends CvModelBase {
  final value = CvField<int>('value').withParent('sub');
  final value2 = CvField<int>('value2').withParent('sub');

  @override
  CvFields get fields => [value, value2];
}

class WithCvModelFieldWithParent extends CvModelBase {
  final value =
      CvModelField<IntContent>.builder('value', builder: (_) => IntContent())
          .withParent('sub');

  @override
  CvFields get fields => [value];
}

class ChildContent extends CvModelBase {
  final sub = CvField<String>('sub');

  @override
  CvFields get fields => [sub];
}

class AllTypes extends CvModelBase {
  final boolCvField = CvField<bool>('bool');
  final intCvField = CvField<int>('int');
  final numCvField = CvField<num>('num');
  final stringCvField = CvField<String>('string');
  final intListCvField = CvListField<int>('intList');
  final stringListCvField = CvListField<String>('stringList');
  final mapCvField = CvField<Map>('map');
  final modelCvField = CvField<Model>('model');
  final listCvField = CvField<List>('list');
  final mapListCvField = CvListField<Map>('mapList');
  final modelListCvField = CvListField<Model>('modelList');
  final children = CvModelListField<WithChildCvField>.builder('children',
      builder: (_) => WithChildCvField());
  final modelMap = CvModelMapField<WithChildCvField>.builder('modelMap',
      builder: (_) => WithChildCvField());

  @override
  CvFields get fields => [
        boolCvField,
        intCvField,
        numCvField,
        stringCvField,
        children,
        intListCvField,
        mapCvField,
        mapListCvField,
        stringListCvField,
        listCvField,
        modelMap,
        modelCvField,
        modelListCvField,
      ];
}

class WithAutoChildren extends CvModelBase {
  final child = CvModelField<ChildContent>('child');
  final children = CvModelListField<ChildContent>('children');

  @override
  CvFields get fields => [child, children];
}

class WithUpdateFields extends CvModelBase {
  final test1 = CvField<int>('test1');
  CvField<int>? test2;

  @override
  CvFields get fields => [test1, if (test2 != null) test2!];
}

class WithEncodedFields extends CvModelBase {
  final test = CvField.encoded<int, String>('test', codec: IntToStringCodec());

  @override
  CvFields get fields => [test];
}

class IntToStringCodec with Codec<int, String> {
  @override
  Converter<String, int> get decoder => const StringToIntConverter();

  @override
  Converter<int, String> get encoder => const IntToStringConverter();
}

abstract class _CommonConverter with Converter<String, String> {
  final WithDependentEncodedFields model;

  const _CommonConverter(this.model);
}

class _ToStringConverter extends _CommonConverter {
  const _ToStringConverter(super.model);

  @override
  String convert(String input) => [model.dep.v ?? '', input].join(',');
}

class _FromStringConverter extends _CommonConverter {
  const _FromStringConverter(super.mode);

  @override
  String convert(String input) {
    var parts = input.split(',');
    if (model.dep.v != parts[0]) {
      throw ArgumentError('Invalid value');
    }
    return parts[1];
  }
}

/// Encrypt codec.
class _CheckDependendentCodec with Codec<String, String> {
  final WithDependentEncodedFields model;

  _CheckDependendentCodec(this.model) {
    encoder = _ToStringConverter(model);
    decoder = _FromStringConverter(model);
  }

  @override
  late final Converter<String, String> decoder;

  @override
  late final Converter<String, String> encoder;
}

class WithDependentEncodedFields extends CvModelBase {
  final dep = CvField<String>('dep');

  // Must be after
  late final test = CvField.encoded<String, String>('test',
      codec: _CheckDependendentCodec(this));

  @override
  CvFields get fields => [dep, test];
}

var lateExample = IntContent()..value.v = 1;
