import 'dart:collection';

import 'package:cv/cv.dart';

import 'content_values.dart';
import 'cv_model_mixin.dart';

/// Empty map.
const cvEmptyMap = <String, Object?>{};

/// New model from an empty map.
T cvNewModel<T extends CvModel>() => cvBuildModel<T>(cvEmptyMap);

/// Cloning a model
T cvClone<T extends CvModel>(T original) {
  var model = cvBuildModel<T>(original.toMap());
  model.copyFrom(original);
  return model;
}

/// New model from an empty map.
T cvTypeNewModel<T extends CvModel>(Type type) =>
    cvTypeBuildModel<T>(type, cvEmptyMap);

/// Read helper
abstract class CvModelRead implements CvModelCore {
  /// Convert to map
  Model toMap({List<String>? columns, bool includeMissingValue = false});
}

/// Write helper (implies CvModelCore)
abstract class CvModelWrite implements CvModelRead {
  /// Map alias
  void fromMap(Map map, {List<String>? columns});

  /// Clear content
  void clear();
}

/// Core model
abstract class CvModelCore {
  /// to override something like [name, description]
  CvFields get fields;

  /// CvField access
  CvField<T>? field<T extends Object?>(String name);
}

/// Modifiable map.
abstract class CvMapModel implements CvModel, Model {
  /// Basic content values factory
  factory CvMapModel() => ContentValuesMap();

  /// Predefined fields, values can be changed but none can added.
  /// Usage discouraged unless you known the limitations.
  factory CvMapModel.withFields(CvFields list) {
    return ContentValues.withCvFields(list);
  }
}

/// Model to access the data (implies CvModelRead and CvModelCore)
abstract class CvModel implements CvModelWrite {}

/// Empty model.
class CvModelEmpty extends CvModelBase {
  @override
  CvFields get fields => [];
}

/// Base content class
///
/// Just defined the fields.
/// ```
/// class Car extends CvModelBase {
///  final engine = CvField<String>('engine');
///  @override
///  CvFields get fields => [engine];
/// }
/// ```
abstract class CvModelBase with CvModelMixin {}

/// Base content class that holds unknown fields in a map.
///
/// Just defined the extra fields.
/// ```
/// class Car extends CvModelBase {
///  final engine = CvField<String>('engine');
///  @override
///  CvFields get fields => [engine];
/// }
/// ```
abstract class CvMapModelBase
    with CvModelMixin, MapModelBaseMixin, MapMixin<String, Object?>
    implements CvMapModel, CvModel, ContentValues {
  /// Default constructor
  CvMapModelBase() {
    initMap();
  }

  CvField<T>? _modelField<T extends Object?>(String name) {
    return modelField<T>(name, fields: modelFields);
  }

  @override
  CvField<T>? field<T extends Object?>(String name) {
    /// Look in model first
    return _modelField<T>(name) ?? mapModelField<T>(name);
  }

  @override
  Object? operator [](Object? key) {
    if (key == null) {
      return null;
    }
    var field = this.field(key.toString());
    return field?.valueOrNull;
  }

  @override
  void operator []=(String key, Object? value) {
    var field = _modelField(key.toString());
    if (field != null) {
      field.value = value;
    } else {
      setMapValue(key, value);
    }
  }

  @override
  void clear() {
    for (var field in modelFields) {
      field.clear();
    }
    clearMap();
  }

  @override
  Object? remove(Object? key) {
    var field = _modelField(key as String);
    if (field != null) {
      var value = field.valueOrNull;
      field.clear();
      return value;
    } else {
      return mapRemove(key);
    }
  }

  @override
  void fromMap(Map? map, {List<String>? columns}) {
    if (map == null) {
      return;
    }
    var modelFields = this.modelFields.columns;
    var modelFieldsSet = modelFields.toSet();
    fromModelMap(map, columns: modelFields);
    map.forEach((key, value) {
      if (modelFieldsSet.contains(key)) {
        return;
      }
      setMapValue(key!.toString(), value);
    });
  }

  /// To implement
  CvFields get modelFields;

  @override
  CvFields get fields => [
    ...modelFields,
    ...getMapKeys().map((key) => mapModelField(key)!),
  ];
}

/// Compilation purpose only.
// ignore: unused_element
class _CvModelMock extends CvModelBase {
  @override
  CvFields get fields => throw UnimplementedError();
}

/// Test fill model utilities.
extension CvModelUtilsExt on CvModel {
  /// Fill all null in model including leaves
  ///
  /// Fill list if listSize is set
  ///
  void fillModel([CvFillOptions? options, List<String>? columns]) {
    var fields = this.fields.matchingColumns(columns);
    for (var field in fields) {
      field.fillField(options);
    }
  }
}

/// Internal ext
extension CvModelInternalExt on CvModelCore {
  /// dynamic field of any type.
  CvField<Object?>? dynamicField(Object key) => field<Object?>(key.toString());
}
