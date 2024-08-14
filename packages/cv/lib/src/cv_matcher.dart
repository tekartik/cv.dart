import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:cv/cv.dart';
import 'package:cv/src/cv_field_with_parent.dart';
import 'package:cv/src/cv_model.dart';
import 'package:matcher/matcher.dart';
import 'package:meta/meta.dart';

class _ModelGenerator {
  final CvFillOptions options;

  _ModelGenerator(this.options);

  CvModel typeGenerateModel(Type type) {
    var model = cvTypeNewModel(type);
    fillModel(model);
    return model;
  }

  /// Fill all null in model including leaves
  ///
  /// Fill list if listSize is set
  ///
  void fillModel(CvModel model, {List<String>? columns}) {
    var fields = model.fields.matchingColumns(columns);
    for (var field in fields) {
      field.fillField(options);
    }
  }

  /// Fill a list.
  void fillListField<T extends Object?>(CvListField<T> field) {
    var collectionSize = options.collectionSize;
    if (collectionSize == null) {
      field.value = null;
    } else {
      var list = field.createList();
      for (var i = 0; i < collectionSize; i++) {
        fillListFieldItem(field, list, i);
      }
      field.value = list;
    }
  }

  /// Fill a list.
  void fillListFieldItem<T extends Object?>(
      CvListField<T> field, List<T> list, int i) {
    if (field is CvModelListField) {
      var item = (field as CvModelListField).create({}) as T;
      fillModel(item as CvModel);
      list.add(item);
    } else if (field is CvListField<Map>) {
      if (options.valueStart != null) {
        list.add(generateMap() as T);
      }
    } else if (field is CvListField<List>) {
      if (options.valueStart != null) {
        // print('list $this');
        list.add(generateList() as T);
      }
    } else {
      if (options.valueStart != null) {
        // print('item $this');
        list.add(generateValue(field.itemType) as T);
      }
    }
  }

  /// Generate a basic map
  Model generateMap({Object Function()? generateMapValue}) {
    var map = newModel();
    var size = options.collectionSize ?? 0;
    for (var i = 0; i < size; i++) {
      map['field_${i + 1}'] =
          generateMapValue != null ? generateMapValue() : generateValue(int);
    }
    return map;
  }

  Object? generateValue(Type type) {
    return options.generateValue(type);
  }

  /// Generate a basic list
  List generateList() {
    var list = <Object?>[];
    var size = options.collectionSize ?? 0;
    for (var i = 0; i < size; i++) {
      list.add(options.generateValue(int));
    }
    return list;
  }

  /// Fill a list.
  void fillModelMapField<T extends CvModel>(CvModelMapField<T> field) {
    var collectionSize = options.collectionSize;
    if (collectionSize == null) {
      field.value = null;
    } else {
      var rawMap = generateMap(generateMapValue: () {
        var item = field.create({});
        fillModel(item);
        return item;
      });
      var map = field.createMap();
      rawMap.forEach((key, value) {
        map[key] = value as T;
      });

      field.value = map;
    }
  }

  void fillModelField<T extends CvModel>(CvModelField<T> field) {
    var modelValue = field.create({});
    fillModel(modelValue);
    field.value = modelValue;
  }

  void fillField<T extends Object?>(CvField field) {
    rawFillField(field);
  }

  void rawFillField<T extends Object?>(CvField field) {
    if (field is CvListField) {
      fillListField(field);
    } else if (field is CvModelMapField) {
      fillModelMapField(field);
    } else if (field is CvModelField) {
      fillModelField(field);
    } else if (field is CvFieldWithParent) {
      fillField(field.field);
    } else if (options.valueStart != null) {
      field.value = options.generateValue(field.type) as T;
    } else {
      // Default to null
      field.value = null;
    }
  }
}

abstract class _SubfieldGenerator {
  void fillModel(CvModel model, {List<String>? columns});
  void wrapInGenerator(
      _SubfieldGenerator subfieldGenerator, void Function() action);

  void fillField(CvField<Object?> field);
}

class _SubfieldGeneratorImpl implements _SubfieldGenerator {
  bool get abort => generator.abort;

  @override
  String toString() => parent == null ? 'root' : '$parent ${field ?? index}';

  _SubfieldGeneratorImpl get parentImpl => parent as _SubfieldGeneratorImpl;
  final _ModelMapMatcherGenerator generator;

  /// Both are nulls at root, never null otherwise.
  final _SubfieldGenerator? parent;
  // Field or index
  final CvField? field;

  /// Only for list field
  final int? index;

  CvModel? get currentFilledMapModel {
    if (parent != null) {
      var parentModel = parentImpl.currentFilledMapModel;
      if (parentModel is! CvMapModel) {
        return null;
      }
      if (field != null) {
        var sourceField = parentModel.dynamicField(field!.name);
        var sourceValue = sourceField?.value;
        if (sourceValue is List) {
          return parentModel;
        }
        if (sourceValue is Map) {
          return CvMapModel()..fromMap(sourceField!.value as Map);
        }
      } else if (index != null) {
        var sourceField = parentModel.dynamicField(parentImpl.field!.name);
        var sourceValue = sourceField?.value;
        if (sourceValue is List) {
          return CvMapModel()..fromMap(sourceValue[index!] as Map);
        }
      }
      return null;
    } else {
      return generator.filledMapModel;
    }
  }

  _SubfieldGeneratorImpl(
      {this.field, required this.parent, required this.generator, this.index});

  _SubfieldGenerator get currentSubfieldGenerator =>
      generator.currentSubfieldGenerator;

  set abort(bool abort) => generator.abort = abort;

  set currentSubfieldGenerator(_SubfieldGenerator currentSubfieldGenerator) =>
      generator.currentSubfieldGenerator = currentSubfieldGenerator;

  @override
  void fillField(CvField field) {
    var subfieldGenerator = _SubfieldGeneratorImpl(
        field: field, parent: this, generator: generator);
    wrapInGenerator(subfieldGenerator, () {
      generator.rawFillField(field);
    });
  }

  @override
  void wrapInGenerator(
      _SubfieldGenerator subfieldGenerator, void Function() action) {
    currentSubfieldGenerator = subfieldGenerator;
    try {
      action();
    } finally {
      currentSubfieldGenerator = this;
    }
  }

  @override
  void fillModel(CvModel model, {List<String>? columns}) {
    var filledMapModel = currentFilledMapModel;
    if (filledMapModel == null) {
      abort = true;
    }
    if (abort) {
      generator.fillModel(model, columns: columns);
    } else {
      var fields = CvFields.from(model.fields.matchingColumns(columns));

      // Fill matching fields field
      var matchingFields = filledMapModel!.fields.matchingColumns(columns);
      for (var matchingField in matchingFields) {
        var field = model.dynamicField(matchingField.name);
        if (field != null) {
          fillField(field);
          fields.remove(field);
        }
      }

      if (fields.isNotEmpty) {
        abort = true;
      }
      // Fill remaining.
      for (var field in fields) {
        fillField(field);
      }
    }
  }
}

class _SubfieldGeneratorRootImpl extends _SubfieldGeneratorImpl {
  _SubfieldGeneratorRootImpl({required super.generator}) : super(parent: null);
}

class _ModelMapMatcherGenerator extends _ModelGenerator {
  final _FillModelMatchesMapMatcher matcher;
  CvMapModel filledMapModel = CvMapModel();
  CvMapModel? currentFilledMapModelOrNull;
  CvMapModel get currentFilledMapModel =>
      currentFilledMapModelOrNull ?? filledMapModel;
  List<Object>? currentKeysOrNull;
  List<Object> get currentKeys => currentKeysOrNull ??= <Object>[];
  late _SubfieldGenerator currentSubfieldGenerator =
      _SubfieldGeneratorRootImpl(generator: this);

  /// Once following matching is cancelled.
  var abort = false;

  _ModelMapMatcherGenerator(this.matcher) : super(matcher.options) {
    filledMapModel = CvMapModel();
    if (matcher.map != null) {
      filledMapModel.fromMap(matcher.map!);
    }
  }

  /// Fill a list.
  @override
  void fillListField<T extends Object?>(CvListField<T> field) {
    var collectionSize = options.collectionSize;
    if (collectionSize == null) {
      field.value = null;
    } else {
      var list = field.createList();
      for (var i = 0; i < collectionSize; i++) {
        var subfieldGenerator = _SubfieldGeneratorImpl(
            field: null,
            parent: currentSubfieldGenerator,
            generator: this,
            index: i);
        currentSubfieldGenerator.wrapInGenerator(subfieldGenerator, () {
          fillListFieldItem(field, list, i);
        });
      }
      field.value = list;
    }
  }

  @override
  void fillField<T extends Object?>(CvField<Object?> field) {
    if (abort) {
      super.fillField(field);
    } else {
      currentSubfieldGenerator.fillField(field);
    }
  }

  /// Fill all null in model including leaves
  ///
  /// Fill list if listSize is set
  ///
  @override
  void fillModel(CvModel model, {List<String>? columns}) {
    if (abort) {
      super.fillModel(model, columns: columns);
    } else {
      currentSubfieldGenerator.fillModel(model, columns: columns);
    }
  }
}

class _FillModelMatchesMapMatcher extends Matcher {
  final CvFillOptions options;
  final Map? map;

  _FillModelMatchesMapMatcher(this.map, CvFillOptions? options)
      : options = options?.copyWith() ?? CvFillOptions();

  CvModel? lastModel;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is Type) {
      var type = item;
      var generator = _ModelMapMatcherGenerator(this);
      var model = cvTypeNewModel(type);
      generator.fillModel(model);
      lastModel = model;
      if (const DeepCollectionEquality().equals(model.toMap(), map)) {
        return true;
      }
    } else if (item is CvModel) {
      return matches(item.runtimeType, matchState);
    }

    return false;
  }

  @override
  Description describe(Description description) {
    description = description.add('expecting map:\n');
    try {
      description = description.add(
          'expecting ${const JsonEncoder.withIndent(' ').convert(lastModel?.toMap())}');
    } catch (e) {
      description = description.add('expecting $lastModel');
    }
    return description;
  }
}

/// Matches a map fill the model, handling any sort order of fields.
///
/// actual value can be a type or an object.
///
/// Not working yet
@experimental
Matcher fillModelMatchesMap(Map map, [CvFillOptions? options]) =>
    _FillModelMatchesMapMatcher(map, options);
