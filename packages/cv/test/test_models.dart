import 'dart:convert';

import 'package:cv/cv.dart';
import 'package:cv/src/builder.dart' show cvRemoveBuilder;

import 'cv_field_test.dart';

class IntContent extends CvModelBase {
  final value = CvField<int>('value');

  @override
  CvFields get fields => [value];
}

class Note extends CvModelBase {
  final title = CvField<String>('title');
  final content = CvField<String>('content');
  final date = CvField<int>('date');

  @override
  CvFields get fields => [title, content, date];
}

class TwoFieldsContent extends CvModelBase {
  final value1 = CvField<int>('value1');
  final value2 = CvField<int>('value2');

  @override
  CvFields get fields => [value1, value2];
}

/// Builder
IntContent intContentBuilder(Map map) => IntContent();

/// This builder is never added, except locally
class NoBuilderIntContent extends CvModelBase {
  final value = CvField<int>('value');

  @override
  CvFields get fields => [value];
}

class TestInnerWithoutBuilder extends CvModelBase {
  final inner = CvModelField<NoBuilderIntContent>('inner');
  @override
  CvFields get fields => [inner];
}

void addNoBuilderIntContentBuilder() {
  cvAddBuilder(noBuilderIntContentBuilder);
}

void removeNoBuilderIntContentBuilder() {
  cvRemoveBuilder(NoBuilderIntContent);
}

/// Builder to add and remove
NoBuilderIntContent noBuilderIntContentBuilder(Map map) =>
    NoBuilderIntContent();

class Custom {
  final String value;

  Custom(this.value);

  @override
  String toString() => value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Custom && (other.value == value);
  }
}

class CustomContent extends CvModelBase {
  final custom1 = CvField<Custom>('custom1');
  final custom2 = CvField<Custom>('custom2');
  final text = CvField<String>('text');

  @override
  CvFields get fields => [custom1, custom2, text];
}

class StringContent extends CvModelBase {
  final value = CvField<String>('value');

  @override
  CvFields get fields => [value];
}

class CloneBaseClass extends CvModelBase {
  final type = CvField<int>('type');
  @override
  CvFields get fields => [type];
}

class CloneBaseClass1 extends CloneBaseClass {}

class CloneBaseClass2 extends CloneBaseClass {}

abstract class AbstractCloneBaseClass extends CvModelBase {
  // 1 for SubClass1, 2 for SubClass 2
  final type = CvField<int>('type');
  final other = CvField<int>('other');
  @override
  CvFields get fields => [type, other];

  AbstractCloneBaseClass();

  /// Constructor tear off for builder
  factory AbstractCloneBaseClass.builder(Map contextData) {
    if (contextData['type'] == 2) {
      return NonAbstractSubClass2();
    } else {
      return NonAbstractSubClass1();
    }
  }
}

class NonAbstractSubClass1 extends AbstractCloneBaseClass {}

class NonAbstractSubClass2 extends AbstractCloneBaseClass {}

class RecursiveContent extends CvModelBase {
  final value = CvField<int>('value');
  final recursive = CvModelField<RecursiveContent>('recursive');
  final recursives = CvModelListField<RecursiveContent>('recursives');
  final recursiveMap = CvModelMapField<RecursiveContent>('recursiveMap');

  @override
  CvFields get fields => [value, recursive, recursives, recursiveMap];
}

class WithDuplicatedCvFields extends CvModelBase {
  final cvField1 = CvField<String>('CvField1');
  final cvField2 = CvField<String>('CvField1');

  @override
  CvFields get fields => [cvField1, cvField2];
}

class WithChildCvField extends CvModelBase {
  final child = CvModelField<ChildContent>.builder(
    'child',
    builder: (_) => ChildContent(),
  );

  @override
  CvFields get fields => [child];
}

class WithGrandChildCvField extends CvModelBase {
  final firstChild = CvModelField<WithChildCvField>.builder(
    'firstChild',
    builder: (_) => WithChildCvField(),
  );

  @override
  CvFields get fields => [firstChild];
}

class WithChildListCvField extends CvModelBase {
  final children = CvModelListField<ChildContent>.builder(
    'children',
    builder: (_) => ChildContent(),
  );

  @override
  CvFields get fields => [children];
}

class WithChildMapCvField extends CvModelBase {
  final children = CvModelMapField<ChildContent>.builder(
    'children',
    builder: (_) => ChildContent(),
  );

  @override
  CvFields get fields => [children];
}

class WithCvFieldWithParent extends CvModelBase {
  final value = CvField<int>('value').withParent('sub');
  final value2 = CvField<int>('value2').withParent('sub');

  @override
  CvFields get fields => [value, value2];
}

class WithCvModelFieldWithParent extends CvModelBase {
  final value = CvModelField<IntContent>.builder(
    'value',
    builder: (_) => IntContent(),
  ).withParent('sub');

  @override
  CvFields get fields => [value];
}

class ChildContent extends CvModelBase {
  final sub = CvField<String>('sub');

  @override
  CvFields get fields => [sub];
}

class AllTypes extends CvModelBase {
  final boolCvField = CvField<bool>('bool');
  final intCvField = CvField<int>('int');
  final numCvField = CvField<num>('num');
  final doubleCvField = CvField<num>('double');
  final stringCvField = CvField<String>('string');
  final intListCvField = CvListField<int>('intList');
  final stringListCvField = CvListField<String>('stringList');
  final mapCvField = CvField<Map>('map');
  final modelCvField = CvField<Model>('model');
  final listCvField = CvField<List>('list');
  final mapListCvField = CvListField<Map>('mapList');
  final modelListCvField = CvListField<Model>('modelList');
  final children = CvModelListField<WithChildCvField>.builder(
    'children',
    builder: (_) => WithChildCvField(),
  );
  final modelMap = CvModelMapField<WithChildCvField>.builder(
    'modelMap',
    builder: (_) => WithChildCvField(),
  );

  @override
  CvFields get fields => [
    boolCvField,
    intCvField,
    numCvField,
    doubleCvField,
    stringCvField,
    children,
    intListCvField,
    mapCvField,
    mapListCvField,
    stringListCvField,
    listCvField,
    modelMap,
    modelCvField,
    modelListCvField,
  ];
}

class WithAutoChildren extends CvModelBase {
  final child = CvModelField<ChildContent>('child');
  final children = CvModelListField<ChildContent>('children');

  @override
  CvFields get fields => [child, children];
}

class WithUpdateFields extends CvModelBase {
  final test1 = CvField<int>('test1');
  CvField<int>? test2;

  @override
  CvFields get fields => [test1, if (test2 != null) test2!];
}

class WithEncodedFields extends CvModelBase {
  final test = CvField.encoded<int, String>('test', codec: IntToStringCodec());

  @override
  CvFields get fields => [test];
}

class IntToStringCodec with Codec<int, String> {
  @override
  Converter<String, int> get decoder => const StringToIntConverter();

  @override
  Converter<int, String> get encoder => const IntToStringConverter();
}

abstract class _CommonConverter with Converter<String, String> {
  final WithDependentEncodedFields model;

  const _CommonConverter(this.model);
}

class _ToStringConverter extends _CommonConverter {
  const _ToStringConverter(super.model);

  @override
  String convert(String input) => [model.dep.v ?? '', input].join(',');
}

class _FromStringConverter extends _CommonConverter {
  const _FromStringConverter(super.mode);

  @override
  String convert(String input) {
    var parts = input.split(',');
    if (model.dep.v != parts[0]) {
      throw ArgumentError('Invalid value');
    }
    return parts[1];
  }
}

/// Encrypt codec.
class _CheckDependendentCodec with Codec<String, String> {
  final WithDependentEncodedFields model;

  _CheckDependendentCodec(this.model) {
    encoder = _ToStringConverter(model);
    decoder = _FromStringConverter(model);
  }

  @override
  late final Converter<String, String> decoder;

  @override
  late final Converter<String, String> encoder;
}

class WithDependentEncodedFields extends CvModelBase {
  final dep = CvField<String>('dep');

  // Must be after
  late final test = CvField.encoded<String, String>(
    'test',
    codec: _CheckDependendentCodec(this),
  );

  @override
  CvFields get fields => [dep, test];
}

var lateExample = IntContent()..value.v = 1;
