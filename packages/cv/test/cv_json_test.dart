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
      for (var text in ['{}', '{"value":null}', '{"value":1}']) {
        expect(text.cv(builder: (_) => IntContent()).toJson(), text);
      }
    });

    test('listFromJson', () {
      for (var text in ['[{}]', '[{"value":null}]', '[{"value":1}]']) {
        expect(text.cvList(builder: (_) => IntContent()).toJson(), text);
      }
    });
  });
}
