import 'package:cv/cv.dart';
import 'package:test/test.dart';

class Simple extends CvModelBase {
  final value = CvField<String>('value');

  @override
  List<CvField> get fields => [value];
}

class Parent extends CvModelBase {
  final child = cvModelField<Child>('child');

  @override
  List<CvField> get fields => [child];
}

class Child extends CvModelBase {
  final value = CvField<String>('value');

  @override
  List<CvField> get fields => [value];
}

class ParentWithList extends CvModelBase {
  final children = cvModelListField<Child>('children');

  @override
  List<CvField> get fields => [children];
}

void initModelBuilders() {
  cvAddBuilder<Parent>((_) => Parent());
  cvAddBuilder<Child>((_) => Child());
  cvAddBuilder<Simple>((_) => Simple());
  cvAddBuilder<ParentWithList>((_) => ParentWithList());
}

void main() {
  initModelBuilders();
  group('builder', () {
    test('simple', () {
      var simple = {'value': 'test'}.cv<Simple>();
      expect(simple.value.v, 'test');
    });
    test('cvModelField', () async {
      var parent = Parent()..child.v = (Child()..value.v = 'test');
      expect(parent.toMap(), {
        'child': {'value': 'test'}
      });
      expect(parent.toMap().cv<Parent>(), parent);
    });
    test('cvModelListField', () async {
      var parent = ParentWithList()..children.v = [Child()..value.v = 'test'];
      expect(parent.toMap(), {
        'children': [
          {'value': 'test'}
        ]
      });
      expect(parent.toMap().cv<ParentWithList>(), parent);
    });
    test('cvBuildModel', () {
      expect(cvBuildModel<Simple>({}), Simple());
      expect(cvTypeBuildModel(Simple, {}), Simple());
    });
  });
}
