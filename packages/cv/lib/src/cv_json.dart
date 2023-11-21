import 'dart:convert';

import 'package:cv/cv.dart';

/// Easy string extension
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
}

/// Easy CvModel extension
extension CvJsonModelExt on CvModel {
  /// to json helper.
  String toJson({List<String>? columns, bool includeMissingValue = false}) =>
      jsonEncode(
          toMap(columns: columns, includeMissingValue: includeMissingValue));
}

/// Easy CvModelList extension
extension CvJsonModelListExt<T extends CvModel> on List<T> {
  /// to json helper.
  String toJson({List<String>? columns, bool includeMissingValue = false}) =>
      jsonEncode(toMapList(
          columns: columns, includeMissingValue: includeMissingValue));
}
