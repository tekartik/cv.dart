import 'package:cv/cv.dart';
import 'package:cv/cv_matcher.dart';
import 'package:cv/utils/value_utils.dart';
import 'package:test/test.dart';

class _Sub extends CvModelBase {
  final map = CvField<Map>('map');
  final list = CvListField<int>('list');
  @override
  CvFields get fields => [map, list];
}

class _Root extends CvModelBase {
  final sub = CvModelField<_Sub>('sub');
  final map = CvField<Map>('map');
  @override
  CvFields get fields => [sub, map];
}

class _ListFirst extends CvModelBase {
  final list = CvListField<int>('list');
  final name = CvField<String>('name');
  @override
  CvFields get fields => [list, name];
}

class _WithModels extends CvModelBase {
  final items = CvModelListField<_Sub>('items');
  final raw = CvField<List>('raw');
  @override
  CvFields get fields => [items, raw];
}

class _Multi extends CvModelBase {
  final name = CvField<String>('name');
  final any = CvMultiField2(CvField<String>('any'), CvField<int>('any'));
  @override
  CvFields get fields => [name, any];
}

class _Recursive extends CvModelBase {
  final value = CvField<int>('value');
  final recursive = CvModelField<_Recursive>('recursive');
  @override
  CvFields get fields => [value, recursive];
}

class _Item extends CvModelBase {
  final name = CvField<String>('name');
  @override
  CvFields get fields => [name];
}

class _Flat extends CvModelBase {
  final d = CvField<double>('d');
  final i = CvField<int>('i');
  final items = CvModelListField<_Item>('items');
  final item = CvModelField<_Item>('item');
  @override
  CvFields get fields => [d, i, items, item];
}

class _WithParent extends CvModelBase {
  final d = CvField<double>('d').withParent('p');
  final i = CvField<int>('i').withParent('p');
  final items = CvModelListField<_Item>('items').withParent('p');
  final item = CvModelField<_Item>('item').withParent('p');
  @override
  CvFields get fields => [d, i, items, item];
}

class _ItemMap extends CvModelBase {
  final map = CvModelMapField<_Item>('map');
  @override
  CvFields get fields => [map];
}

class _NullableItems extends CvModelBase {
  final list = CvListField<int?>('list');
  @override
  CvFields get fields => [list];
}

class _MapBased extends CvMapModelBase {
  final a = CvField<int>('a');
  final b = CvField<int>('b');
  @override
  CvFields get modelFields => [a, b];
}

void main() {
  cvAddConstructors([
    _Sub.new,
    _Root.new,
    _ListFirst.new,
    _WithModels.new,
    _Multi.new,
    _Recursive.new,
    _Item.new,
  ]);
  group('regression', () {
    test('tree value set through a nested model', () {
      var root = _Root()
        ..fromMap({
          'sub': {
            'map': {
              'a': [1, 2],
            },
          },
        });
      var treeValue = root.cvTreeValueAtPath<int>(
        CvTreePath(['sub', 'map', 'a', 0]),
      );
      expect(treeValue.found, isTrue);
      expect(treeValue.value, 1);
      treeValue.setValue(10);
      expect(root.sub.v!.map.v, {
        'a': [10, 2],
      });
    });

    test('tree value out of range index', () {
      var root = _Root()
        ..fromMap({
          'sub': {
            'list': [5],
          },
        });
      for (var index in [1, 3, -1]) {
        var treeValue = root.cvTreeValueAtPath<int>(
          CvTreePath(['sub', 'list', index]),
        );
        expect(treeValue.found, isFalse);
        expect(treeValue.value, isNull);
      }
    });

    test('hashCode consistent with == for list and map values', () {
      var field1 = CvField<List>('field', [1]);
      var field2 = CvField<List>('field', [1]);
      expect(field1, field2);
      expect(field1.hashCode, field2.hashCode);
      var mapField1 = CvField<Map>('field', {'a': 1});
      var mapField2 = CvField<Map>('field', {'a': 1});
      expect(mapField1.hashCode, mapField2.hashCode);
      var parentField1 = CvField<List>('field', [1]).withParent('parent');
      var parentField2 = CvField<List>('field', [1]).withParent('parent');
      expect(parentField1, parentField2);
      expect(parentField1.hashCode, parentField2.hashCode);

      var model1 = _ListFirst()
        ..list.v = [1, 2]
        ..name.v = 'a';
      var model2 = _ListFirst()
        ..list.v = [1, 2]
        ..name.v = 'a';
      expect(model1, model2);
      expect(model1.hashCode, model2.hashCode);
      // Equal models dedupe in sets.
      expect({model1, model2}, hasLength(1));
    });

    test('hashCode of a model without fields', () {
      expect(CvModelEmpty().hashCode, 0);
      expect(CvMapModel().hashCode, 0);
      expect({CvMapModel(), CvMapModel()}, hasLength(1));
    });

    test('CvFieldPath and CvTreePath equality is symmetric', () {
      var fieldPath = CvFieldPath(const ['a', 1]);
      var treePath = CvTreePath(['a', 1]);
      expect(treePath, fieldPath);
      expect(fieldPath, treePath);
      expect(fieldPath.hashCode, treePath.hashCode);
      expect({fieldPath, treePath}, hasLength(1));
      expect({treePath, fieldPath}, hasLength(1));
    });

    test('negative list index', () {
      var model = _WithModels()
        ..fromMap({
          'items': [
            {
              'list': [1],
            },
          ],
          'raw': [1, 2],
        });
      expect(model.items.v!.fieldAtPath<Object?>([-1, 'list']), isNull);
      expect(model.fieldAtPath<Object?>(['items', -1, 'list']), isNull);
      expect(model.fieldAtPath<Object?>(['raw', -1]), isNull);
      expect([1, 2].rawFieldAtPath<Object?>([-1]), isNull);
    });

    test('withParent converts the value like a field without parent', () {
      var data = {
        'd': 1,
        'i': '12',
        'items': [
          {'name': 'a'},
        ],
        'item': {'name': 'b'},
      };
      var expected = {
        'd': 1.0,
        'i': 12,
        'items': [
          {'name': 'a'},
        ],
        'item': {'name': 'b'},
      };
      expect((_Flat()..fromMap(data)).toMap(), expected);
      expect((_WithParent()..fromMap({'p': data})).toMap(), {'p': expected});
      // Not a map, the sub model is not set.
      expect(
        (_WithParent()..fromMap({
              'p': {'item': 'b'},
            }))
            .toMap(),
        isEmpty,
      );
    });

    test('multi field read again forgets the previous value', () {
      var model = _Multi()..fromMap({'any': 'text'});
      expect(model.toMap(), {'any': 'text'});
      model.fromMap({'any': 1});
      expect(model.toMap(), {'any': 1});
      model.fromMap({'any': null});
      expect(model.toMap()['any'], isNull);
      model.fromMap({'any': 'text'});
      expect(model.toMap(), {'any': 'text'});
    });

    test('field path text with a dot read back', () {
      for (var parts in [
        ['a.b', 'c'],
        ['a.b', 1, '2'],
        ['a', '1.2', 'b.c.d'],
        ['.', 'a'],
      ]) {
        var text = CvFieldPath(parts).text;
        expect(CvFieldPath.fromString(text).parts, parts, reason: text);
      }
      // Not enclosed, unchanged.
      expect(CvFieldPath.fromString('`a.b').parts, ['`a', 'b']);
      expect(CvFieldPath.fromString('a`.b`').parts, ['a`', 'b`']);
      expect(CvFieldPath.fromString('`a`b.c').parts, ['`a`b', 'c']);
    });

    test('map model hashCode independent of the key order', () {
      var model1 = CvMapModel()..fromMap({'a': 1, 'b': 2});
      var model2 = CvMapModel()..fromMap({'b': 2, 'a': 1});
      expect(model1, model2);
      expect(model1.hashCode, model2.hashCode);
      expect({model1, model2}, hasLength(1));
    });

    test('build from a type registered with cvAddConstructors', () {
      // Registered with the common super type of the list.
      expect(cvTypeBuildModel<_Item>(_Item, {}), isA<_Item>());
      expect(cvTypeNewModel<_Item>(_Item), isA<_Item>());
      expect({'name': 'a'}.cvType<_Item>(_Item).name.v, 'a');
      expect(
        [
          {'name': 'a'},
        ].cvType<_Item>(_Item).first.name.v,
        'a',
      );
    });

    test('list field of a nullable type holds null', () {
      var model = _NullableItems()
        ..fromMap({
          'list': [1, null, 2],
        });
      expect(model.list.v, [1, null, 2]);
      expect(model.toMap(), {
        'list': [1, null, 2],
      });
    });

    test('map model fromMap columns', () {
      var model = _MapBased()
        ..fromMap({'a': 1, 'b': 2, 'c': 3, 'd': 4}, columns: ['a', 'c']);
      expect(model.toMap(), {'a': 1, 'c': 3});
      model = _MapBased()..fromMap({'a': 1, 'b': 2, 'c': 3});
      expect(model.toMap(), {'a': 1, 'b': 2, 'c': 3});
    });

    test('int from NaN or infinity is null', () {
      expect(basicTypeToInt('1e400'), isNull);
      expect(basicTypeToInt('-1e400'), isNull);
      expect(basicTypeToInt('NaN'), isNull);
      expect(basicTypeToInt('Infinity'), isNull);
      expect(basicTypeToInt(double.infinity), isNull);
      expect(basicTypeToInt(double.nan), isNull);
      expect(basicTypeToInt('1.6'), 2);
      expect(basicTypeCast<int>(double.negativeInfinity), isNull);
    });

    test('deepClone keeps the values of non string keys', () {
      expect(<Object?, Object?>{1: 'one', 'a': 'b'}.deepClone(), {
        '1': 'one',
        'a': 'b',
      });
    });

    test('model map field skips what is not a model map', () {
      var model = _ItemMap()
        ..fromMap({
          'map': {
            'a': {'name': 'a'},
            'b': null,
            'c': {'name': 'c'},
            'd': 'text',
          },
        });
      expect(model.toMap(), {
        'map': {
          'a': {'name': 'a'},
          'c': {'name': 'c'},
        },
      });
    });

    test('fillModelMatchesMap multi field and recursive model', () {
      for (var type in [_Multi, _Recursive]) {
        var map = (cvTypeNewModel(type)..fillModel(cvFillOptions1)).toMap();
        expect(type, fillModelMatchesMap(map, cvFillOptions1));
      }
    });
  });
}
