import 'dart:convert';

import 'package:cv/cv.dart';

/// Easy string extension
extension CvJsonStringExt on String {
  /// Create an object from a json string.
  T cv<T extends CvModel>({T Function(Map contextData)? builder}) {
    var map = asModel(jsonDecode(this) as Map);
    return map.cv<T>(builder: builder);
  }

  /// Create a list from a json string
  List<T> cvList<T extends CvModel>({T Function(Map contextData)? builder}) {
    var list = asModelList(jsonDecode(this) as List);
    return list.cv<T>(builder: builder);
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
