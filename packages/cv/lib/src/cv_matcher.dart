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
        if (this is CvModelListField) {
          var item = (this as CvModelListField).create({}) as T;
          fillModel(item as CvModel);
          list.add(item);
        } else if (this is CvListField<Map>) {
          if (options.valueStart != null) {
            list.add(generateMap() as T);
          }
        } else if (this is CvListField<List>) {
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
      field.value = list;
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

class _ModelMapMatcherGenerator extends _ModelGenerator {
  final _FillModelMatchesMapMatcher matcher;
  CvMapModel filledMapModel = CvMapModel();

  /// Once following matching is cancelled.
  var abort = false;

  _ModelMapMatcherGenerator(this.matcher) : super(matcher.options) {
    filledMapModel = CvMapModel();
    if (matcher.map != null) {
      filledMapModel.fromMap(matcher.map!);
    }
  }

  /// Fill all null in model including leaves
  ///
  /// Fill list if listSize is set
  ///
  @override
  void fillModel(CvModel model, {List<String>? columns}) {
    var fields = CvFields.from(model.fields.matchingColumns(columns));

    // Fill matching fields field
    var matchingFields = filledMapModel.fields.matchingColumns(columns);
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
      if (DeepCollectionEquality().equals(model.toMap(), map)) {
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
          'expecting ${JsonEncoder.withIndent(' ').convert(lastModel?.toMap())}');
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
