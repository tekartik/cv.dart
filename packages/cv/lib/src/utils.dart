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

/// Basic type extension definition.
extension CvBasicTypeExt on Type {
  /// True for num, String, bool, int, double.
  bool get isBasicType {
    if (this == num ||
        this == String ||
        this == bool ||
        this == int ||
        this == double) {
      return true;
    }
    return false;
  }
}

/// If 2 models are equals
@Deprecated('Use cvModelsAreEquals')
bool cvModelAreEquals(CvModelRead model1, CvModelRead model2) =>
    cvModelsAreEquals(model1, model2);

/// If 2 models are equals
bool cvModelsAreEquals(
  CvModelRead model1,
  CvModelRead model2, {
  List<String>? columns,
}) {
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
/// num are rounded to int if needed
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
    return basicTypeToInt(value) as T?;
  } else if (T == num) {
    return basicTypeToNum(value) as T?;
  } else if (T == double) {
    return basicTypeToDouble(value) as T?;
  } else if (T == bool) {
    return basicTypeToBool(value) as T?;
  } else {
    throw UnsupportedError('Unsupported type $T');
  }
}

/// Handle int, num, double, String, bool
///
/// num are truncated to int if needed
/// 1 (or non 0) or 0 are handle in bool
///
Object? _nonNullBasicTypeCastType(Type type, Object value) {
  if (type == String) {
    if (value is String) {
      return value;
    } else {
      return value.toString();
    }
  } else if (type == int) {
    return basicTypeToInt(value);
  } else if (type == num) {
    return basicTypeToNum(value);
  } else if (type == double) {
    return basicTypeToDouble(value);
  } else if (type == bool) {
    return basicTypeToBool(value);
  } else if (type == Object || type == dynamic) {
    return value;
  } else {
    throw UnsupportedError('Unsupported type $type for value $value');
  }
}

/// Handle int, num, double, String, bool
///
/// [bool]
///   non 0/null nom value are converted to true
/// [int], [double]
///   num are rounder to int if needed

T? basicTypeCast<T extends Object?>(Object? value) {
  if (value == null) {
    return null;
  } else {
    return _nonNullBasicTypeCast<T>(value);
  }
}

/// Handle int, num, double, String, bool
///
/// [bool]
///   non 0/null nom value are converted to true
/// [int], [double]
///   num are rounder to int if needed

Object? basicTypeCastType(Type type, Object? value) {
  if (value == null) {
    return null;
  } else {
    return _nonNullBasicTypeCastType(type, value);
  }
}

/// true as 1, false as 0, null as null,
/// rounded to int
int? basicTypeToInt(Object? value) {
  /// But most likely to happen first
  if (value is int) {
    return value;
  } else if (value == null) {
    return null;
  } else if (value is num) {
    return value.round();
  } else if (value is bool) {
    return value ? 1 : 0;
  } else if (value is String) {
    return _parseInt(value);
  } else {
    return _parseInt(value.toString());
  }
}

/// parse any double or parse as int
double? basicTypeToDouble(Object? value) {
  /// But most likely to happen first
  if (value is double) {
    return value;
  } else if (value == null) {
    return null;
  } else if (value is int) {
    return value.toDouble();
  } else if (value is bool) {
    return value ? 1.0 : 0.0;
  } else if (value is String) {
    return _parseDouble(value);
  } else {
    return _parseDouble(value.toString());
  }
}

/// parse any bool or parse as null num
bool? basicTypeToBool(Object? value) {
  /// But most likely to happen first
  if (value is bool) {
    return value;
  } else if (value == null) {
    return null;
  } else if (value is num) {
    return value != 0;
  } else if (value is String) {
    return _parseBool(value);
  } else {
    return _parseBool(value.toString());
  }
}

/// num or int or parse string
num? basicTypeToNum(Object? value) {
  /// But most likely to happen first
  if (value is num) {
    return value;
  } else if (value == null) {
    return null;
  } else if (value is bool) {
    return value ? 1 : 0;
  } else if (value is String) {
    return _parseNum(value);
  } else {
    return _parseNum(value.toString());
  }
}

int? _parseInt(String value) {
  if (value.isEmpty) {
    return null;
  }
  var intValue = int.tryParse(value);
  if (intValue != null) {
    return intValue;
  }
  return num.tryParse(value)?.round();
}

num? _parseNum(String value) {
  if (value.isEmpty) {
    return null;
  }
  return num.tryParse(value);
}

double? _parseDouble(String value) {
  if (value.isEmpty) {
    return null;
  }
  var doubleValue = double.tryParse(value);
  if (doubleValue != null) {
    return doubleValue;
  }
  return num.tryParse(value)?.toDouble();
}

/// Also parse any number as true if non zero
bool? _parseBool(String value) {
  if (value.isEmpty) {
    return null;
  }
  var boolValue = bool.tryParse(value);
  if (boolValue != null) {
    return boolValue;
  }

  var numValue = num.tryParse(value);
  if (numValue != null) {
    return (numValue != 0);
  }
  return null;
}
