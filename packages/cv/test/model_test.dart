import 'package:cv/cv.dart';
import 'package:cv/src/typedefs.dart';
import 'package:test/test.dart';

List<Map> get listWithOneEmptyModel => [{}];
void main() {
  group('model', () {
    test('value', () {
      // ignore: prefer_collection_literals
      var model = Model();
      model.setValue('test', 'text');
    });

    test('entry', () {
      expect(ModelEntry('test', null).key, 'test');
      expect(ModelEntry('test', 'value').value, 'value');
    });

    test('value', () {
      var model = newModel();
      model.setValue('test', 'text');
      expect(model.getValue<String>('test'), 'text');
      expect(model.getMapEntry('test')!.value, 'text');
      model.setValue('test', null);
      expect(model.getValue<String>('test'), isNull);
      expect(model.containsKey('test'), isFalse);
      model.setValue('test', null, presentIfNull: true);
      expect(model.getValue<String>('test'), isNull);
      expect(model.containsKey('test'), isTrue);
    });

    test('model', () {
      var model = <K, V>{};
      expect(model.getMapEntry('test'), isNull);
      model['test'] = null;
      expect(model.getMapEntry('test')!.value, isNull);
      model['test'] = 'a';
      expect(model.getMapEntry('test')!.value, 'a');
      model['test'] = null;
      expect(model.getMapEntry('test')!.value, isNull);
      model.remove('test');
      expect(model.getMapEntry('test'), isNull);

      model = asModel({'test': 'a'});
      expect(model.getMapEntry('test')!.value, 'a');
      model = asModel({'test': null});
      expect(model.getMapEntry('test')!.value, null);
    });

    group('model_list', () {
      test('simple', () {
        var list = <Model>[];
        var modelList1 = <Model>[];
        var modelList2 = asModelList([]);

        var lists = <List>[list, modelList1, modelList2];
        // expect(model.getEntry('test'), ModelEntry('test', null));
        void doTest(Map value) {
          for (var list in lists) {
            list.add(asModel(value));
            expect(list.last, value);

            list.addAll(<Model>[asModel(value)]);
            expect(list.last, value);
          }
        }

        //_test(null);
        doTest({});

        list = <Model>[];
        list.add(asModel({'a': 1}));
      });

      test('cast', () {
        var list = asModelList([<Object?, Object?>{}]);
        expect(list[0], const TypeMatcher<Model>());
      });
    });

    test('model_base', () {
      var map = <Object?, Object?>{};
      var model1 = <K, V>{};
      var model2 = asModel({});

      var maps = [map, model1, model2];

      void doTest(dynamic value) {
        for (var map in maps) {
          map['test'] = value;
          expect(map['test'], value);
          if (map is Model) {
            expect(map.getMapEntry('test')!.value, value);
          }
        }
      }

      doTest(null);
      doTest('a');
      doTest(<Object?>[]);
      doTest(<Object?>{});
      for (var map in maps) {
        map.remove('test');
        expect(map['test'], isNull);
        if (map is Model) {
          expect(map.getMapEntry('test'), isNull);
        }
      }
    });

    test('asModel', () {
      expect(asModel({}), isEmpty);
      expect(asModel({'test': 1}), {'test': 1});
      expect(asModel({}), const TypeMatcher<Model>());
    });

    test('cvOverride', () {
      expect(asModel({})..cvOverride(CvField('test')), isEmpty);
      expect(asModel({})..cvOverride(CvField.withNull('test')), {'test': null});
      expect(asModel({})..cvOverride(CvField('test', 1)), {'test': 1});
      expect(asModel({})..cvOverride(CvField('test', 1), 2), {'test': 2});
    });
    test('cvRemove', () {
      expect(asModel({'test': 2, 'other': 3})..cvRemove(CvField('test', 1)),
          {'other': 3});
      expect(asModel({'test': 2})..cvRemove(CvField('test')), isEmpty);
    });
    test('cvSetNull', () {
      expect(asModel({})..cvSetNull(CvField('test', 1)), {'test': null});
      expect(asModel({})..cvSetNull(CvField('test')), {'test': null});
    });
  });
}
