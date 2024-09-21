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
abstract class CvModelBase with CvModelMixin {}

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
