import 'package:cv/cv.dart';
// ignore: deprecated_member_use_from_same_package

import 'package:test/test.dart';

import 'cv_model_test.dart';

void main() {
  test('path simple', () {
    var model = IntContent()..value.v = 1;
    expect(model.path.value.path.parts, ['value']);
  });
  test('path sub', () {
    var model = WithChildCvField();
    expect(model.path.child.sub.sub.path.parts, ['child', 'sub']);
  });

  test('path grand child', () {
    var model = WithGrandChildCvField();
    expect(model.path.firstChild.sub.child.sub.sub.path.parts,
        ['firstChild', 'child', 'sub']);
  });

  test('path list simple', () {
    var model = AllTypes();
    expect(model.path.intListCvField.path.parts, ['intList']);
    expect(model.path.intListCvField.at(1).parts, ['intList', 1]);
  });
  test('path list model', () {
    var model = AllTypes();
    expect(model.path.children.path.parts, ['children']);
    expect(model.path.children.at(1).parts, ['children', 1]);
    expect(model.path.children.subAt(5).child.path.parts,
        ['children', 5, 'child']);
    expect(model.path.children.subAt(5).child.sub.sub.path.parts,
        ['children', 5, 'child', 'sub']);
  });
}
