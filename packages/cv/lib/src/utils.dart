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

/// Handle int, num, double, String, bool
///
/// num are rounder to int if needed
/// 1 or 0 are handle in bool
/// bool are converted to int or double 1 or 0 if forced
T? _stringBasicTypeCast<T extends Object?>(String value) {
  if (T == String) {
    return value as T;
  } else if (T == int) {
    var intValue = int.tryParse(value) as T?;
    if (intValue != null) {
      return intValue;
    }
    return num.tryParse(value)?.toInt() as T?;
  } else if (T == num) {
    return num.tryParse(value) as T?;
  } else if (T == double) {
    var doubleValue = double.tryParse(value);
    if (doubleValue != null) {
      return doubleValue as T;
    }
    return num.tryParse(value)?.toDouble() as T?;
  } else if (T == bool) {
    var boolValue = bool.tryParse(value) as T?;
    if (boolValue != null) {
      return boolValue;
    }
    var numValue = _stringBasicTypeCast<num>(value);
    if (numValue != null) {
      return (numValue != 0) as T;
    }
  }
  return null;
}

/// Handle int, num, double, String, bool
///
/// num are truncated to int if needed
/// 1 (or non 0) or 0 are handle in bool
///
T? _nonNullBasicTypeCast<T extends Object?>(Object value) {
  if (T == String) {
    if (value is String) {
      return value as T;
    } else {
      return value.toString() as T;
    }
  } else if (T == int) {
    if (value is int) {
      return value as T;
    }
    if (value is num) {
      return value.toInt() as T;
    }
    if (value is bool) {
      return (value ? 1 : 0) as T;
    }
    return _stringBasicTypeCast<T>(value.toString());
  } else if (T == num) {
    if (value is num) {
      return value as T;
    }
    if (value is bool) {
      return (value ? 1 : 0) as T;
    }
    return _stringBasicTypeCast<T>(value.toString());
  } else if (T == double) {
    if (value is double) {
      return value as T;
    }
    if (value is num) {
      return value.toDouble() as T;
    }
    if (value is bool) {
      return (value ? 1.0 : 0.0) as T;
    }
    return _stringBasicTypeCast<T>(value.toString());
  } else if (T == bool) {
    if (value is bool) {
      return value as T;
    } else if (value is num) {
      return (value != 0) as T;
    }
    return _stringBasicTypeCast<T>(value.toString());
  } else {
    throw UnsupportedError('Unsupported type $T');
  }
}

/// Handle int, num, double, String, bool
///
/// <bool>
///   non 0/null nom value are converted to true
/// <int>, <double>
///   num are rounder to int if needed

T? basicTypeCast<T extends Object?>(Object? value) {
  if (value == null) {
    return null;
  } else {
    return _nonNullBasicTypeCast<T>(value);
  }
}
