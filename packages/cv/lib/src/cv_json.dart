import 'dart:convert';

import 'package:cv/cv.dart';

/// Easy string extension, assume a json encoded
extension CvJsonStringExt on String {
  /// Create an object from a json string.
  T cv<T extends CvModel>({T Function(Map contextData)? builder}) {
    return jsonToMap().cv<T>(builder: builder);
  }

  /// Create an object from a json string.
  T cvType<T extends CvModel>(Type type,
      {T Function(Map contextData)? builder}) {
    return jsonToMap().cvType<T>(type, builder: builder);
  }

  /// Create a list from a json string.
  ///
  /// If [lazy] is true, the object in the list are converted when needed.
  List<T> cvList<T extends CvModel>(
      {T Function(Map contextData)? builder, bool lazy = true}) {
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
          toMap(columns: columns, includeMissingValue: includeMissingValue));

  /// to json helper.
  String toJsonPretty(
          {List<String>? columns, bool includeMissingValue = false}) =>
      jsonPrettyEncode(
          toMap(columns: columns, includeMissingValue: includeMissingValue));
}

/// Easy CvModelList extension
extension CvJsonModelListExt<T extends CvModel> on List<T> {
  /// to json helper.
  String toJson({List<String>? columns, bool includeMissingValue = false}) =>
      jsonEncode(toMapList(
          columns: columns, includeMissingValue: includeMissingValue));

  /// to json helper using 2 spaces indent.
  String toJsonPretty(
          {List<String>? columns, bool includeMissingValue = false}) =>
      jsonPrettyEncode(toMapList(
          columns: columns, includeMissingValue: includeMissingValue));
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
