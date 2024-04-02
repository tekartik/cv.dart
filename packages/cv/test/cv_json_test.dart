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

    test('CvModel.toJson', () async {
      expect(IntContent().toJson(), '{}');
      expect(IntContent().toJson(includeMissingValue: true), '{"value":null}');
      expect((IntContent()..value.v = 1).toJson(), '{"value":1}');
      expect((IntContent()..value.v = null).toJson(), '{"value":null}');
      expect((IntContent()..value.setValue(null)).toJson(), '{}');

      expect((IntContent()..value.setValue(null, presentIfNull: true)).toJson(),
          '{"value":null}');
      expect((IntContent()..value.v = 1).toJson(columns: <String>[]), '{}');
      expect(
          (IntContent()..value.v = 1).toJson(columns: <String>['other']), '{}');
      expect(
          (IntContent()..value.v = 1).toJson(columns: [IntContent().value.k]),
          '{"value":1}');
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

    test('jsonToMapList', () {
      expect('[]'.jsonToMapList(), isEmpty);
      expect('[{"test": 1}]'.jsonToMapList(), [
        {'test': 1}
      ]);
      try {
        expect('{}'.jsonToMapList(), isEmpty);
        fail('should fail');
      } catch (_) {}
      try {
        expect(''.jsonToMapList(), isEmpty);
        fail('should fail');
      } catch (_) {}
    });
  });
}
