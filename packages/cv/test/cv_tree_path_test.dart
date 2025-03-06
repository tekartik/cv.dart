import 'package:cv/cv.dart';

import 'package:test/test.dart';

import 'cv_model_test.dart';

void main() {
  test('path simple', () {
    var model = IntContent()..value.v = 1;
    expect(model.cvPath.value.treePath.parts, ['value']);
  });
  test('path sub', () {
    var model = WithChildCvField();
    expect(model.cvPath.child.pathSub.sub.treePath.parts, ['child', 'sub']);
  });

  test('path grand child', () {
    var model = WithGrandChildCvField();
    expect(model.cvPath.firstChild.pathSub.child.pathSub.sub.treePath.parts, [
      'firstChild',
      'child',
      'sub',
    ]);
  });

  test('path list simple', () {
    var model = AllTypes();
    expect(model.cvPath.intListCvField.treePath.parts, ['intList']);
    expect(model.cvPath.intListCvField.treePathAt(1).parts, ['intList', 1]);
  });
  test('path list model', () {
    var model = AllTypes();
    expect(model.cvPath.children.treePath.parts, ['children']);
    expect(model.cvPath.children.treePathAt(1).parts, ['children', 1]);
    expect(model.cvPath.children.pathSubAt(5).child.treePath.parts, [
      'children',
      5,
      'child',
    ]);
    expect(
      model.cvPath.children.pathSubAt(5).child.pathSub.sub.treePath.parts,
      ['children', 5, 'child', 'sub'],
    );
  });
  test('path map model', () {
    var model = WithChildMapCvField();
    expect(model.cvPath.children.pathSubAt('test').cvPath.sub.treePath.parts, [
      'children',
      'test',
      'sub',
    ]);
  });
  test('tree value', () {
    var model = AllTypes();
    var tmv = model.cvTreeValueAtPath<bool>(CvTreePath(['bool']));
    expect(tmv.model, model);
    expect(tmv.type, bool);
    expect(tmv.value, isNull);
    model.boolCvField.v = true;
    tmv = model.cvTreeValueAtPath<bool>(CvTreePath(['bool']));
    expect(tmv.model, model);
    expect(tmv.type, bool);
    expect(tmv.value, true);
    expect(tmv.found, isTrue);
    tmv.setValue(false);
    expect(model.boolCvField.v, isFalse);
  });
  test('tree cv child', () {
    var model = WithChildCvField();
    expect(
      model.cvPath.child.pathSub.sub.treePath,
      CvTreePath(['child', 'sub']),
    );
    var tmv = model.cvTreeValueAtPath<bool>(CvTreePath(['child', 'sub']));
    expect(tmv.model, model);
    expect(tmv.type, isNull);
    expect(tmv.value, isNull);
    expect(tmv.found, isFalse);
    model.child.v = ChildContent()..sub.v = 'sub_v';
    var tmvString = model.cvTreeValueAtPath<String>(
      CvTreePath(['child', 'sub']),
    );
    expect(tmvString.type, String);
    expect(tmvString.value, 'sub_v');
    expect(tmvString.found, isTrue);

    tmvString.setValue('alt_sub_v');
    expect(model.child.v!.sub.v, 'alt_sub_v');
  });

  test('tree cv model list', () {
    var model = WithChildListCvField();
    expect(
      model.cvPath.children.pathSubAt(0).sub.treePath,
      CvTreePath(['children', 0, 'sub']),
    );
    var tmv = model.cvTreeValueAtPath<bool>(CvTreePath(['child', 'sub']));
    expect(tmv.model, model);
    expect(tmv.type, isNull);
    expect(tmv.value, isNull);
    expect(tmv.found, isFalse);
    model.children.v = [ChildContent()..sub.v = 'sub_v'];
    var tmvString = model.cvTreeValueAtPath<String>(
      CvTreePath(['children', 0, 'sub']),
    );
    expect(tmvString.type, String);
    expect(tmvString.value, 'sub_v');
    expect(tmvString.found, isTrue);

    tmvString.setValue('alt_sub_v');
    expect(model.children.v![0].sub.v, 'alt_sub_v');
  });
  test('tree cv list item', () {
    var model = AllTypes();
    expect(
      model.cvPath.intListCvField.treePathAt(0),
      CvTreePath(['intList', 0]),
    );
    var tmv = model.cvTreeValueAtPath<int>(CvTreePath(['intList', 1]));
    expect(tmv.model, model);
    expect(tmv.type, isNull);
    expect(tmv.value, isNull);
    expect(tmv.found, isFalse);
    model.intListCvField.v = [1, 2, 3];
    var tmvInt = model.cvTreeValueAtPath<int>(CvTreePath(['intList', 1]));
    expect(tmvInt.type, int);
    expect(tmvInt.value, 2);
    expect(tmvInt.found, isTrue);
    tmvInt.setValue(4);
    expect(model.intListCvField.v, [1, 4, 3]);
  });
  test('complex', () {
    var model = newAllTypes1();
    var parts = ['modelMap', 'field_1', 'child', 'sub'];
    expect(model.valueAtPath<String>(parts), 'text_12');
    var tmv = model.cvTreeValueAtPath<String>(CvTreePath(parts));
    expect(tmv.model, model);
    expect(tmv.type, String);
    expect(tmv.value, 'text_12');
    expect(tmv.found, isTrue);
    tmv.setValue('alt_text_12');
    expect(tmv.value, 'alt_text_12');
    expect(model.valueAtPath<String>(parts), 'alt_text_12');
  });
}
