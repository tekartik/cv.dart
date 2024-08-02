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
final _builders = () {
  var map = <Type, Object Function(Map data)>{};
  // Always add the map model
  map[CvMapModel] = (_) => CvMapModel();
  return map;
}();

/// Add builder that uses builder function
void cvAddBuilder<T extends CvModel>(CvModelBuilderFunction<T> builder) {
  _builders[T] = builder;
}

/// Add builder that uses builder function
void cvTypeAddBuilder(Type type, CvModelBuilderFunction<Object> builder) {
  _builders[type] = builder;
}

/// Get a builder.
CvModelBuilderFunction<T>? _cvGetBuilderOrNull<T extends CvModel>(
    {CvModelBuilderFunction<T>? builder}) {
  var foundBuilder = builder ?? _builders[T];
  if (foundBuilder is CvModelBuilderFunction<T>?) {
    return foundBuilder;
  } else {
    return (Map contextData) => foundBuilder(contextData) as T;
  }
}

/// Get a builder.
CvModelBuilderFunction<T> cvGetBuilder<T extends CvModel>(
    {CvModelBuilderFunction<T>? builder}) {
  var foundBuilder = _cvGetBuilderOrNull<T>(builder: builder);
  if (foundBuilder == null) {
    throw CvBuilderExceptionImpl('Missing builder for \'$T\', call addBuilder');
  }
  return foundBuilder;
}

/// Get a builder from a type.
CvModelBuilderFunction<T> cvTypeGetBuilder<T extends CvModel>(Type type,
    {CvModelBuilderFunction<T>? builder}) {
  var foundBuilder = cvTypeGetBuilderOrNull<T>(type, builder: builder);
  if (foundBuilder == null) {
    throw CvBuilderExceptionImpl(
        'Missing builder for type \'$type\', call addBuilder');
  }
  return foundBuilder;
}

/// Get a builder from a type.
CvModelBuilderFunction<T>? cvTypeGetBuilderOrNull<T extends CvModel>(Type type,
    {CvModelBuilderFunction<T>? builder}) {
  var foundBuilder = builder ?? _builders[type];
  return foundBuilder as CvModelBuilderFunction<T>?;
}

/// Add convenient constructor tear-off
void cvAddConstructor<T extends CvModel>(
    CvModelDefaultBuilderFunction<T> builder) {
  cvAddBuilder<T>((_) => builder());
}

/// Add convenient constructors tear-off
///
/// Warning each builder must be of the same base type
/// i.e. use a different construction for CvMapModel and CvModelBase models and
/// other based)
void cvAddConstructors<T extends CvModel>(
    List<CvModelDefaultBuilderFunction<T>> builders) {
  for (var builder in builders) {
    /// Here T might not be ok so lets build it!
    var object = builder();
    cvTypeAddBuilder(object.runtimeType, (contextData) => builder());
  }
}

/// Remove builder
@visibleForTesting
void cvRemoveBuilder(Type type) {
  _builders.remove(type);
}

/// Remove builders
@visibleForTesting
void cvRemoveBuilders(List<Type> types) {
  for (var type in types) {
    cvRemoveBuilder(type);
  }
}

/// Build a model but does not import the data.
T cvBuildModel<T extends CvModel>(Map contextData,
    {CvModelBuilderFunction<T>? builder}) {
  var foundBuilder = cvGetBuilder<T>(builder: builder);
  return foundBuilder(contextData);
}

/// Build a model but does not import the data.
T cvTypeBuildModel<T extends CvModel>(Type type, Map contextData,
    {T Function(Map contextData)? builder}) {
  var foundBuilder = cvTypeGetBuilder<T>(type, builder: builder);
  return foundBuilder(contextData);
}

/// Auto field
CvModelField<T> cvModelField<T extends CvModel>(String name) =>
    CvModelField<T>(name);

/// Auto field
CvModelListField<T> cvModelListField<T extends CvModel>(String name) =>
    CvModelListField<T>(name);

/// Easy extension
extension CvMapExt on Map {
  /// Create an entry from a map
  T cv<T extends CvModel>({T Function(Map contextData)? builder}) {
    return cvBuildModel<T>(this, builder: builder)..fromMap(this);
  }

  /// Create an entry from a map
  T cvType<T extends CvModel>(Type type,
      {T Function(Map contextData)? builder}) {
    return cvTypeBuildModel<T>(type, this, builder: builder)..fromMap(this);
  }
}

/// Easy extension
extension CvMapListExt on List<Map> {
  /// Create a list of CvModel from a snapshot
  List<T> cv<T extends CvModel>({T Function(Map contextData)? builder}) =>
      map((map) => map.cv<T>(builder: builder)).toList();

  /// Create a list of CvModel from a snapshot
  List<T> cvType<T extends CvModel>(Type type,
          {T Function(Map contextData)? builder}) =>
      map((map) => map.cvType<T>(type, builder: builder)).toList();
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
