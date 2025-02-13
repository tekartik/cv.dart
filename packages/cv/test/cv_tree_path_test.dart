import 'package:cv/cv.dart';
// ignore: deprecated_member_use_from_same_package

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
}
