import 'package:cv/cv.dart';
import 'package:cv/src/builder.dart' show cvRemoveBuilder, cvRemoveBuilders;
import 'package:test/test.dart';

import 'model_test.dart';

class Simple extends CvModelBase {
  final value = CvField<String>('value');

  @override
  CvFields get fields => [value];
}

class Parent extends CvModelBase {
  final child = cvModelField<Child>('child');

  @override
  CvFields get fields => [child];
}

class Child extends CvModelBase {
  final value = CvField<String>('value');

  @override
  CvFields get fields => [value];
}

class ParentWithList extends CvModelBase {
  final children = cvModelListField<Child>('children');

  @override
  CvFields get fields => [children];
}

abstract class BaseClass extends CvModelBase {
  // 1 for SubClass1, 2 for SubClass 2
  final type = CvField<int>('type');
  @override
  CvFields get fields => [type];

  BaseClass();

  /// Constructor tear off for builder
  factory BaseClass.builder(Map contextData) {
    if (contextData['type'] == 2) {
      return SubClass2();
    } else {
      return SubClass1();
    }
  }
}

class SubClass1 extends BaseClass {}

class SubClass2 extends BaseClass {}

void initModelBuilders() {
  cvAddBuilder<Parent>((_) => Parent());
  cvAddBuilder<Child>((_) => Child());
  cvAddBuilder<Simple>((_) => Simple());
  cvAddBuilder<ParentWithList>((_) => ParentWithList());
}

class MissingBuilder extends CvModelBase {
  final value = CvField<String>('value');

  @override
  CvFields get fields => [value];
}

class ParentWithMissingBuilderChild extends CvModelBase {
  final child = CvModelField<MissingBuilder>('child');

  @override
  CvFields get fields => [child];
}

class ParentWithMissingBuilderChildren extends CvModelBase {
  final children = CvModelListField<MissingBuilder>('children');

  @override
  CvFields get fields => [children];
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
        'child': {'value': 'test'},
      });
      expect(parent.toMap().cv<Parent>(), parent);
    });
    test('cvModelListField', () async {
      var parent = ParentWithList()..children.v = [Child()..value.v = 'test'];
      expect(parent.toMap(), {
        'children': [
          {'value': 'test'},
        ],
      });
      expect(parent.toMap().cv<ParentWithList>(), parent);
    });
    test('cvBuildModel', () {
      expect(cvBuildModel<Simple>({}), Simple());
      expect(cvTypeBuildModel(Simple, {}), Simple());
    });

    test('missing builder', () {
      try {
        newModel().cv<MissingBuilder>();
        fail('should fail');
      } on CvBuilderException catch (e) {
        expect(
          e.toString(),
          contains('Missing builder for \'MissingBuilder\''),
        );
      }
      try {
        newModel().cvType(MissingBuilder);
        fail('should fail');
      } on CvBuilderException catch (e) {
        expect(
          e.toString(),
          contains('Missing builder for type \'MissingBuilder\''),
        );
      }

      cvAddBuilder<ParentWithMissingBuilderChild>(
        (_) => ParentWithMissingBuilderChild(),
      );
      try {
        (newModel()..['child'] = {}).cv<ParentWithMissingBuilderChild>();
        fail('should fail');
      } on CvBuilderException catch (e) {
        expect(
          e.toString(),
          contains('Missing builder for \'MissingBuilder\''),
        );
      }

      cvAddBuilder<ParentWithMissingBuilderChildren>(
        (_) => ParentWithMissingBuilderChildren(),
      );
      try {
        (newModel()..['children'] = listWithOneEmptyModel)
            .cv<ParentWithMissingBuilderChildren>();
        fail('should fail');
      } on CvBuilderException catch (e) {
        expect(
          e.toString(),
          contains('Missing builder for \'MissingBuilder\''),
        );
      }
    });
    test('Sub class', () {
      cvAddBuilder(BaseClass.builder);
      var base = {'type': 1}.cv<BaseClass>();
      expect(base, const TypeMatcher<SubClass1>());
      base = {'type': 2}.cv<BaseClass>();
      expect(base, const TypeMatcher<SubClass2>());
    });

    test('Constructor tear-off class', () {
      cvRemoveBuilder(SubClass1);
      cvRemoveBuilder(SubClass2);
      cvAddConstructor(SubClass1.new);
      cvAddConstructor(SubClass2.new);
      BaseClass base = newModel().cv<SubClass1>();
      expect(base, const TypeMatcher<SubClass1>());
      base = newModel().cv<SubClass2>();
      expect(base, const TypeMatcher<SubClass2>());
    });
    test('Constructor tear-off class', () {
      cvRemoveBuilder(SubClass1);
      cvRemoveBuilder(SubClass2);

      for (var tearOff in [SubClass1.new, SubClass2.new]) {
        cvAddConstructor(tearOff);
      }
      BaseClass base = newModel().cv<SubClass1>();
      expect(base, const TypeMatcher<SubClass1>());
      base = newModel().cv<SubClass2>();
      expect(base, const TypeMatcher<SubClass2>());
    }, skip: 'This does not work (yet)');

    test('getBuilders', () {
      var existingBuilder = cvGetBuilder<Simple>();
      expect(cvTypeGetBuilder(Simple), existingBuilder);
      cvAddConstructor(Simple.new);
      existingBuilder = cvGetBuilder<Simple>();
      expect(cvTypeGetBuilder(Simple), existingBuilder);
      var simple1 = Simple()..value.v = 'test';
      expect(simple1.toMap().cvType(Simple), simple1);
    });

    test('addConstructors', () {
      cvRemoveBuilders([Simple, Child]);
      cvAddConstructors([Simple.new, Child.new]);
      expect(cvNewModel<Simple>(), isA<Simple>());
      expect(cvNewModel<Child>(), isA<Child>());
    });
  });
}
