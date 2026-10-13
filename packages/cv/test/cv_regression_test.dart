import 'package:cv/cv.dart';
import 'package:cv/cv_matcher.dart';
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

void main() {
  cvAddConstructors([
    _Sub.new,
    _Root.new,
    _ListFirst.new,
    _WithModels.new,
    _Multi.new,
    _Recursive.new,
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

    test('fillModelMatchesMap multi field and recursive model', () {
      for (var type in [_Multi, _Recursive]) {
        var map = (cvTypeNewModel(type)..fillModel(cvFillOptions1)).toMap();
        expect(type, fillModelMatchesMap(map, cvFillOptions1));
      }
    });
  });
}
