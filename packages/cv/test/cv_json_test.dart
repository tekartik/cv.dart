import 'dart:convert';

import 'package:cv/cv_json.dart';
import 'package:test/test.dart';

import 'cv_model_test.dart';

void main() {
  group('cv', () {
    test('CvModel', () {
      var model = CvMapModel();
      model['test'] = 1;
      expect(model.toJson(), '{"test":1}');
    });
    test('jsonPrettyEncode', () {
      expect(jsonEncode(null), 'null');
      expect(jsonPrettyEncode(1), '1');
      expect(jsonPrettyEncode(1.5), '1.5');
      expect(jsonPrettyEncode('test'), '"test"');
      expect(jsonPrettyEncode(true), 'true');
      expect(jsonPrettyEncode(null), 'null');
      expect(json.decode('null'), isNull);
      expect(jsonPrettyEncode({}), '{}');
      var list = ['test', 1];
      var map = {'test': 1};
      expect(jsonPrettyEncode(list), '[\n  "test",\n  1\n]');
      expect(jsonPrettyEncode(map), '{\n  "test": 1\n}');
      expect(map.cvToJsonPretty(), jsonPrettyEncode(map));
      expect(map.cvToJson(), jsonEncode(map));
      expect(list.cvToJsonPretty(), jsonPrettyEncode(list));
      expect(list.cvToJson(), jsonEncode(list));
      var model = CvMapModel();
      model['test'] = 1;
      expect(model.toJsonPretty(), jsonPrettyEncode(map));
      expect('{"test":1}'.cvToJsonPretty(), jsonPrettyEncode(map));
      expect('["test",1]'.cvToJsonPretty(), jsonPrettyEncode(list));
    });

    test('CvModel.toJson', () async {
      expect(IntContent().toJson(), '{}');
      expect(IntContent().toJson(includeMissingValue: true), '{"value":null}');
      expect((IntContent()..value.v = 1).toJson(), '{"value":1}');
      expect((IntContent()..value.v = null).toJson(), '{"value":null}');
      expect((IntContent()..value.setValue(null)).toJson(), '{}');

      expect(
        (IntContent()..value.setValue(null, presentIfNull: true)).toJson(),
        '{"value":null}',
      );
      expect((IntContent()..value.v = 1).toJson(columns: <String>[]), '{}');
      expect(
        (IntContent()..value.v = 1).toJson(columns: <String>['other']),
        '{}',
      );
      expect(
        (IntContent()..value.v = 1).toJson(columns: [IntContent().value.k]),
        '{"value":1}',
      );
    });
    test('CvModelList.toJson', () async {
      expect([IntContent()].toJson(), '[{}]');
      expect([(IntContent()..value.v = 1)].toJson(), '[{"value":1}]');
    });
    test('fromJson', () {
      cvAddConstructor<IntContent>(IntContent.new);
      for (var text in ['{}', '{"value":null}', '{"value":1}']) {
        expect(text.cv<IntContent>().toJson(), text);
      }
      // int
      expect('{"value":1.1}'.cv<IntContent>().toMap(), {'value': 1});
      expect('{"value":2.999}'.cv<IntContent>().toMap(), {'value': 3});
    });

    test('listFromJson', () {
      for (var text in ['[{}]', '[{"value":null}]', '[{"value":1}]']) {
        expect(text.cvList(builder: (_) => IntContent()).toJson(), text);
      }
    });
    test('jsonToMap', () {
      expect('{}'.jsonToMap(), isEmpty);
      expect('{"test": 1}'.jsonToMap(), {'test': 1});
      try {
        expect('[]'.jsonToMap(), isEmpty);
        fail('should fail');
      } catch (_) {}
      try {
        expect(''.jsonToMap(), isEmpty);
        fail('should fail');
      } catch (_) {}
    });

    test('jsonToMapOrNull', () {
      expect('{}'.jsonToMapOrNull(), isEmpty);
      expect('{"test": 1}'.jsonToMapOrNull(), {'test': 1});

      expect('[]'.jsonToMapOrNull(), isNull);
      expect(''.jsonToMapOrNull(), isNull);
    });

    test('jsonToMapList', () {
      expect('[]'.jsonToMapList(), isEmpty);
      expect('[{"test": 1}]'.jsonToMapList(), [
        {'test': 1},
      ]);
      try {
        expect('{}'.jsonToMapList(), isEmpty);
        fail('should fail');
      } catch (e) {
        expect(e, isNot(isA<TestFailure>()));
      }
      try {
        expect(''.jsonToMapList(), isEmpty);
        fail('should fail');
      } catch (e) {
        expect(e, isNot(isA<TestFailure>()));
      }

      try {
        expect('[1]'.jsonToMapList(), isEmpty);
        fail('should fail');
      } catch (e) {
        expect(e, isNot(isA<TestFailure>()));
      }
    });

    test('jsonToList', () {
      expect('[]'.jsonToList(), isEmpty);
      expect('[1]'.jsonToList(), [1]);
      expect('[{"test": 1}]'.jsonToList(), [
        {'test': 1},
      ]);
      try {
        expect('{}'.jsonToList(), isEmpty);
        fail('should fail');
      } catch (e) {
        // TypeError: Instance of '_JsonMap': type '_JsonMap' is not a subtype of type 'List<dynamic>'
        // print(e);
        expect(e, isNot(isA<TestFailure>()));
      }
      try {
        expect(''.jsonToList(), isEmpty);
        fail('should fail');
      } catch (e) {
        expect(e, isNot(isA<TestFailure>()));
      }
    });
    test('jsonToListOrNull', () {
      expect('[]'.jsonToListOrNull(), isEmpty);
      expect('[1]'.jsonToListOrNull(), [1]);
      expect('[{"test": 1}]'.jsonToList(), [
        {'test': 1},
      ]);

      expect('{}'.jsonToListOrNull(), isNull);

      expect(''.jsonToListOrNull(), isNull);
    });
    test('cvAnyToJsonObjectOrNull', () {
      expect(cvAnyToJsonObjectOrNull(null), isNull);
      expect(cvAnyToJsonObjectOrNull(1), null);
      var map = {'test': 1};
      expect(cvAnyToJsonObjectOrNull(map), map);
      expect(cvAnyToJsonObjectOrNull(jsonEncode(map)), map);
    });
    test('cvAnyToJsonObjectOrNull', () {
      expect(cvAnyToJsonArrayOrNull(null), isNull);
      expect(cvAnyToJsonArrayOrNull(1), null);
      var list = [
        {'test': 1},
        2,
      ];
      expect(cvAnyToJsonArrayOrNull(list), list);
      expect(cvAnyToJsonArrayOrNull(jsonEncode(list)), list);
    });
  });
}
