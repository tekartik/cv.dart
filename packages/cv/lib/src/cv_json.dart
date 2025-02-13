import 'dart:convert';

import 'package:cv/cv.dart';

/// Decode any object
Model? cvAnyToJsonObjectOrNull(Object? source) {
  if (source is Map) {
    return source.cast<String, Object?>();
  } else if (source is String) {
    return _parseJsonObjectOrNull(source)?.cast<String, Object?>();
  }
  return null;
}

/// Decode any object list
List<Object?>? cvAnyToJsonArrayOrNull(Object? source) {
  if (source is List) {
    return _castList(source);
  } else if (source is String) {
    return _parseJsonListOrNull(source);
  }
  return null;
}

List<Object?>? _castList(List? list) => list?.cast<Object?>();

/// Safely parse a list
List<Object?>? _parseJsonListOrNull(String? text) {
  var list = _parseJsonStringOrNull(text);
  if (list is List) {
    return _castList(list);
  }
  return null;
}

/// Safely parse a map
Map<String, Object?>? _parseJsonObjectOrNull(String? text) {
  var map = _parseJsonStringOrNull(text);
  if (map is Map) {
    return map.cast<String, Object?>();
  }
  return null;
}

/// safely parse text or null
Object? _parseJsonStringOrNull(String? text) {
  if (text != null) {
    try {
      return json.decode(text);
    } catch (_) {}
  }
  return null;
}

/// Easy string extension, assume a json encoded
extension CvJsonStringExt on String {
  /// Create an object from a json string.
  T cv<T extends CvModel>({T Function(Map contextData)? builder}) {
    return jsonToMap().cv<T>(builder: builder);
  }

  /// Create an object from a json string.
  T cvType<T extends CvModel>(
    Type type, {
    T Function(Map contextData)? builder,
  }) {
    return jsonToMap().cvType<T>(type, builder: builder);
  }

  /// Create a list from a json string.
  ///
  /// If [lazy] is true, the object in the list are converted when needed.
  List<T> cvList<T extends CvModel>({
    T Function(Map contextData)? builder,
    bool lazy = true,
  }) {
    return jsonToMapList().cv<T>(builder: builder, lazy: lazy);
  }

  /// Decode string as a map.
  Model jsonToMap() {
    return asModel(jsonDecode(this) as Map);
  }

  /// Decode string as a list.
  ModelList jsonToMapList() {
    return asModelList(jsonDecode(this) as List);
  }

  /// to json helper using 2 spaces indent.
  String cvToJsonPretty() => jsonPrettyEncode(jsonDecode(this));
}

/// Easy CvModel extension
extension CvJsonModelExt on CvModel {
  /// to json helper.
  String toJson({List<String>? columns, bool includeMissingValue = false}) =>
      jsonEncode(
        toMap(columns: columns, includeMissingValue: includeMissingValue),
      );

  /// to json helper.
  String toJsonPretty({
    List<String>? columns,
    bool includeMissingValue = false,
  }) => jsonPrettyEncode(
    toMap(columns: columns, includeMissingValue: includeMissingValue),
  );
}

/// Easy CvModelList extension
extension CvJsonModelListExt<T extends CvModel> on List<T> {
  /// to json helper.
  String toJson({List<String>? columns, bool includeMissingValue = false}) =>
      jsonEncode(
        toMapList(columns: columns, includeMissingValue: includeMissingValue),
      );

  /// to json helper using 2 spaces indent.
  String toJsonPretty({
    List<String>? columns,
    bool includeMissingValue = false,
  }) => jsonPrettyEncode(
    toMapList(columns: columns, includeMissingValue: includeMissingValue),
  );
}

/// Easy Map extension
extension CvJsonMapExt on Map {
  /// to json helper.
  String cvToJson() => jsonEncode(this);

  /// to json helper using 2 spaces indent.
  String cvToJsonPretty() => jsonPrettyEncode(this);
}

/// Easy Map extension
extension CvJsonListExt on List {
  /// to json helper.
  String cvToJson() => jsonEncode(this);

  /// to json helper using 2 spaces indent.
  String cvToJsonPretty() => jsonPrettyEncode(this);
}

const _cvJsonPrettyPrintEncoder = JsonEncoder.withIndent('  ');

/// Encode object to json with 2 spaces indent.
String jsonPrettyEncode(Object? object) {
  return _cvJsonPrettyPrintEncoder.convert(object);
}
