import 'package:cv/cv.dart';
import 'package:meta/meta.dart';

/// A model builder function should only build the model but should not
/// fill it with the data.
///
/// data is for context to eventually decide to instantiate a different sub
/// class.
typedef CvModelBuilderFunction<T extends Object> = T Function(Map contextData);

/// A model default builder takes no arguments and only create the object
/// without context.
typedef CvModelDefaultBuilderFunction<T extends Object> = T Function();

/// Global builder map
var _builders = <Type, Object Function(Map data)>{};

/// Add builder that uses builder function
void cvAddBuilder<T extends CvModel>(CvModelBuilderFunction<T> builder) {
  _builders[T] = builder;
}

/// Add convenient constructor tear-off
void cvAddConstructor<T extends CvModel>(
    CvModelDefaultBuilderFunction<T> builder) {
  cvAddBuilder<T>((_) => builder());
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
      throw CvBuilderExceptionImpl('Missing builder for $T, call addBuilder');
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
      throw CvBuilderExceptionImpl(
          'Missing builder for $type, call addBuilder');
    }
    return foundBuilder(contextData) as T;
  } else {
    return builder(contextData);
  }
}

/// Auto field
CvModelField<T> cvModelField<T extends CvModel>(String name) =>
    CvModelField<T>(name);

/// Auto field
CvModelListField<T> cvModelListField<T extends CvModel>(String name) =>
    CvModelListField<T>(name);

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

/// CvBuilder exception.
abstract class CvBuilderException implements Exception {}

/// Internal exception
class CvBuilderExceptionImpl implements CvBuilderException {
  /// Internal message
  final String message;

  /// Internal exception.
  CvBuilderExceptionImpl(this.message);

  @override
  String toString() => message;
}
