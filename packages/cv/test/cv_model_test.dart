import 'dart:convert';

import 'package:cv/cv.dart';
import 'package:cv/src/builder.dart';
import 'package:cv/src/cv_model_mixin.dart';
import 'package:test/test.dart';

CvFillOptions get testFillOptions =>
    CvFillOptions(valueStart: 0, collectionSize: 1);

class Note extends CvModelBase {
  final title = CvField<String>('title');
  final content = CvField<String>('content');
  final date = CvField<int>('date');

  @override
  List<CvField> get fields => [title, content, date];
}

class IntContent extends CvModelBase {
  final value = CvField<int>('value');

  @override
  List<CvField> get fields => [value];
}

/// Builder
IntContent intContentBuilder(Map map) => IntContent();

/// This builder is never added, except locally
class NoBuilderIntContent extends CvModelBase {
  final value = CvField<int>('value');

  @override
  List<CvField> get fields => [value];
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
  List<CvField> get fields => [
        custom1,
        custom2,
        text,
      ];
}

class StringContent extends CvModelBase {
  final value = CvField<String>('value');

  @override
  List<CvField> get fields => [value];
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
      expect(IntContent().toMap(), {});
      expect(IntContent().toMap(includeMissingValue: true), {'value': null});
      expect((IntContent()..value.v = 1).toMap(), {'value': 1});
      expect((IntContent()..value.v = null).toMap(), {'value': null});
      expect((IntContent()..value.setValue(null)).toMap(), {});

      expect((IntContent()..value.setValue(null, presentIfNull: true)).toMap(),
          {'value': null});
      expect((IntContent()..value.v = 1).toMap(columns: <String>[]), {});
      expect((IntContent()..value.v = 1).toMap(columns: <String>['other']), {});
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
      expect(cv.toMap(), {});
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
      expect(cv.toMap(), {});
    });
    test('alltoMap', () async {
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
      expect(WithDuplicatedCvFields().toMap(), {});
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
      expect(WithChildCvField().toMap(), {});
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
      expect(WithChildListCvField().toMap(), {});
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
    test('all types', () {
      AllTypes? allTypes;
      void _check() {
        var export = allTypes!.toMap();
        var import = AllTypes()..fromMap(export);
        expect(import, allTypes);
        expect(import.toMap(), allTypes.toMap());
        import = AllTypes()..fromMap(jsonDecode(jsonEncode(export)) as Map);

        expect(import.toMap(), allTypes.toMap());
      }

      allTypes = AllTypes();
      _check();
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
      _check();
    });

    test('fillModel', () {
      expect(
          (CvModelField<IntContent>('int', (_) => IntContent())
                ..fillModel(CvFillOptions(valueStart: 0)))
              .v,
          IntContent()..value.v = 1);
    });

    test('fillModelList', () {
      expect(
          (CvModelListField<IntContent>('int', (_) => IntContent())
                ..fillList(CvFillOptions(collectionSize: 1, valueStart: 0)))
              .v,
          [IntContent()..value.v = 1]);
    });

    test('fillModel', () {
      expect((IntContent()..fillModel()).toMap(), {'value': null});
      expect((WithChildCvField()..fillModel()).toMap(), {
        'child': {'sub': null}
      });
      expect((WithChildListCvField()..fillModel()).toMap(), {'children': null});
      expect((AllTypes()..fillModel()).toMap(), {
        'bool': null,
        'int': null,
        'num': null,
        'string': null,
        'children': null,
        'intList': null,
        'map': null,
        'mapList': null,
        'stringList': null,
        'list': null
      });
    });
    test('fillModel', () {
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
      expect(
          (AllTypes()
                ..fillModel(CvFillOptions(valueStart: 0, collectionSize: 1)))
              .toMap(),
          {
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
            'list': [10]
          });
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
      expect(WithCvFieldWithParent().toMap(), {});

      var field = WithCvFieldWithParent()
        ..fromMap({
          'sub': {'value': 1}
        });
      expect(field.value.v, 1);
      expect(field.toMap(), {
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
  });
}

class WithDuplicatedCvFields extends CvModelBase {
  final cvField1 = CvField<String>('CvField1');
  final cvField2 = CvField<String>('CvField1');

  @override
  List<CvField> get fields => [cvField1, cvField2];
}

class WithChildCvField extends CvModelBase {
  final child = CvModelField<ChildContent>('child', (_) => ChildContent());

  @override
  List<CvField> get fields => [child];
}

class WithChildListCvField extends CvModelBase {
  final children =
      CvModelListField<ChildContent>('children', (_) => ChildContent());

  @override
  List<CvField> get fields => [children];
}

class WithCvFieldWithParent extends CvModelBase {
  final value = CvField<int>('value').withParent('sub');
  final value2 = CvField<int>('value2').withParent('sub');

  @override
  List<CvField> get fields => [value, value2];
}

class WithCvModelFieldWithParent extends CvModelBase {
  final value =
      CvModelField<IntContent>('value', (_) => IntContent()).withParent('sub');

  @override
  List<CvField> get fields => [value];
}

class ChildContent extends CvModelBase {
  final sub = CvField<String>('sub');

  @override
  List<CvField> get fields => [sub];
}

class AllTypes extends CvModelBase {
  final boolCvField = CvField<bool>('bool');
  final intCvField = CvField<int>('int');
  final numCvField = CvField<num>('num');
  final stringCvField = CvField<String>('string');
  final intListCvField = CvListField<int>('intList');
  final stringListCvField = CvListField<String>('stringList');
  final mapCvField = CvField<Map>('map');
  final listCvField = CvField<List>('list');
  final mapListCvField = CvListField<Map>('mapList');
  final children =
      CvModelListField<WithChildCvField>('children', (_) => WithChildCvField());

  @override
  List<CvField> get fields => [
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
      ];
}

class WithAutoChildren extends CvModelBase {
  final child = CvModelField<ChildContent>('child');
  final children = CvModelListField<ChildContent>('children');

  @override
  List<CvField> get fields => [child, children];
}

class WithUpdateFields extends CvModelBase {
  final test1 = CvField<int>('test1');
  CvField<int>? test2;
  @override
  List<CvField> get fields => [test1, if (test2 != null) test2!];
}

var lateExample = IntContent()..value.v = 1;
