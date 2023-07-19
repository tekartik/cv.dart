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

/// If 2 models are equals
@Deprecated('Use cvModelsAreEquals')
bool cvModelAreEquals(CvModelRead model1, CvModelRead model2) =>
    cvModelsAreEquals(model1, model2);

/// If 2 models are equals
bool cvModelsAreEquals(CvModelRead model1, CvModelRead model2,
    {List<String>? columns}) {
  if (columns == null) {
    if (model1.fields.length != model2.fields.length) {
      return false;
    }
    for (var cvField in model2.fields) {
      if (model1.dynamicField(cvField.name) != cvField) {
        return false;
      }
    }
  } else {
    for (var column in columns) {
      var field1 = model1.dynamicField(column);
      var field2 = model2.dynamicField(column);
      if (field1 != field2) {
        return false;
      }
    }
  }
  return true;
}
