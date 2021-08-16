import 'package:cv/cv.dart';
import 'package:meta/meta.dart';

/// Global builder map
var _builders = <Type, Function(Map data)>{};

/// Add builder
void cvAddBuilder<T extends CvModel>(T Function(Map contextData) builder) {
  _builders[T] = builder;
}

/// Remove builder
@visibleForTesting
void cvRemoveBuilder(Type type) {
  _builders.remove(type);
}

/// Build a model but does not import the data.
T cvBuildModel<T extends CvModel>(Map contextData,
    {T Function(Map contextData)? builder}) {
  if (builder == null) {
    var foundBuilder = _builders[T];
    if (foundBuilder == null) {
      throw UnsupportedError('Missing builder for $T, call addBuilder');
    }
    return foundBuilder(contextData) as T;
  } else {
    return builder(contextData);
  }
}

/// Build a model but does not import the data.
T cvTypeBuildModel<T extends CvModel>(Type type, Map contextData,
    {T Function(Map contextData)? builder}) {
  if (builder == null) {
    var foundBuilder = _builders[type];
    if (foundBuilder == null) {
      throw UnsupportedError('Missing builder for $type, call addBuilder');
    }
    return foundBuilder(contextData) as T;
  } else {
    return builder(contextData);
  }
}

/// Auto field
CvModelField<T> cvModelField<T extends CvModel>(String name) =>
    CvModelField<T>(name, (data) => cvBuildModel<T>(data as Map));

/// Auto field
CvModelListField<T> cvModelListField<T extends CvModel>(String name) =>
    CvModelListField<T>(name, (data) => cvBuildModel<T>(data as Map));

/// Easy extension
extension CvMapExt on Map {
  /// Create an antry from a map
  T cv<T extends CvModel>({T Function(Map contextData)? builder}) {
    return cvBuildModel<T>(this, builder: builder)..fromMap(this);
  }
}

/// Easy extension
extension CvMapListExt on List<Map> {
  /// Create a list of DbRecords from a snapshot
  List<T> cv<T extends CvModel>({T Function(Map contextData)? builder}) =>
      map((map) => map.cv<T>(builder: builder)).toList();
}
