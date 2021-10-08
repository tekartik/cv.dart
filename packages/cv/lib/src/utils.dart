import 'package:cv/src/cv_model.dart';

/// True for null, num, String, bool
bool isBasicTypeOrNull(dynamic value) {
  if (value == null) {
    return true;
  } else if (value is num || value is String || value is bool) {
    return true;
  }
  return false;
}

/// If 2 content are equals
bool cvModelAreEquals(CvModelRead model1, CvModelRead model2) {
  if (model1.fields.length != model2.fields.length) {
    return false;
  }
  for (var cvField in model2.fields) {
    if (model1.field(cvField.name) != cvField) {
      return false;
    }
  }
  return true;
}

/// True if the type is nullable
bool typeIsNullable<T>() => null is T;
