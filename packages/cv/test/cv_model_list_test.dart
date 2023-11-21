import 'package:cv/cv.dart';
import 'package:test/test.dart';

import 'cv_model_test.dart';
import 'model_test.dart';

void main() {
  group('cv', () {
    test('CvModel', () {
      var model = CvMapModel();
      model['test'] = 1;
    });

    test('toMapList', () async {
      expect([IntContent()].toMapList(), listWithOneEmptyModel);

      expect([(IntContent()..value.v = 1)].toMapList(), [
        {'value': 1}
      ]);
      expect([(IntContent()..value.v = 1)].toMapList(columns: ['value']), [
        {'value': 1}
      ]);
      expect([(IntContent()..value.v = 1)].toMapList(columns: ['other']),
          listWithOneEmptyModel);
    });
    test('toMapList', () async {
      expect([IntContent()].toMapList(), listWithOneEmptyModel);

      expect([(IntContent()..value.v = 1)].toMapList(), [
        {'value': 1}
      ]);
    });
    test('cvNewModelList', () async {
      cvAddConstructor(IntContent.new);
      expect(cvNewModelList<IntContent>(), isA<List<IntContent>>());
      expect(cvTypeNewModelList<CvModel>(IntContent), isA<List<CvModel>>());

      expect(
          [
            {'value': 1}
          ].cv<IntContent>(),
          [IntContent()..value.v = 1]);
      expect(
          [
            {'value': 1}
          ].cvType(IntContent),
          [IntContent()..value.v = 1]);
    });
    test('CvModelList.cv', () async {
      cvAddConstructor(IntContent.new);
      expect(listWithOneEmptyModel.cv<IntContent>(), [IntContent()]);

      expect(
          [
            {'value': 1}
          ].cv<IntContent>(),
          [IntContent()..value.v = 1]);
      expect(
          [
            {'value': 1}
          ].cvType(IntContent),
          [IntContent()..value.v = 1]);
    });
    test('CvModelList.cv', () async {
      expect(listWithOneEmptyModel.cv<IntContent>(builder: intContentBuilder),
          [IntContent()]);

      expect(
          [
            {'value': 1}
          ].cv<IntContent>(builder: intContentBuilder),
          [IntContent()..value.v = 1]);
      expect(
          [
            {'value': 1}
          ].cvType(IntContent, builder: intContentBuilder),
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
