import 'package:cv/cv.dart';
import 'package:test/test.dart';

import 'cv_model_test.dart';

void main() {
  group('cv', () {
    test('CvModel', () {
      var model = CvMapModel();
      model['test'] = 1;
    });

    test('toMapList', () async {
      expect([IntContent()].toMapList(), [{}]);

      expect([(IntContent()..value.v = 1)].toMapList(), [
        {'value': 1}
      ]);
      expect([(IntContent()..value.v = 1)].toMapList(columns: ['value']), [
        {'value': 1}
      ]);
      expect([(IntContent()..value.v = 1)].toMapList(columns: ['other']), [{}]);
    });
    test('toMapList', () async {
      expect([IntContent()].toMapList(), [{}]);

      expect([(IntContent()..value.v = 1)].toMapList(), [
        {'value': 1}
      ]);

      expect([{}].cv<IntContent>(builder: intContentBuilder), [IntContent()]);

      expect([{}].cv<IntContent>(builder: intContentBuilder), [IntContent()]);
    });
    test('CvModelList.cv', () async {
      expect([{}].cv<IntContent>(builder: intContentBuilder), [IntContent()]);

      expect(
          [
            {'value': 1}
          ].cv<IntContent>(builder: intContentBuilder),
          [IntContent()..value.v = 1]);
    });
    test('CvModelList no builder', () {
      expect(
          [
            {'value': 1}
          ].cv<NoBuilderIntContent>(builder: noBuilderIntContentBuilder),
          [IntContent()..value.v = 1]);
      try {
        [
          {'value': 1}
        ].cv<NoBuilderIntContent>();
      } on CvBuilderException catch (_) {}

      try {
        addNoBuilderIntContentBuilder();
        expect(
            [
              {'value': 1}
            ].cv<NoBuilderIntContent>(),
            [IntContent()..value.v = 1]);
      } finally {
        removeNoBuilderIntContentBuilder();
      }
    });
  });
}
