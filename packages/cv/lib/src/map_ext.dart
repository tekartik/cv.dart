import 'package:cv/cv.dart';
import 'package:cv/cv.dart' as cvimpl;
import 'package:cv/src/typedefs.dart';

String _keyPartToString(Object part) {
  if (part is int) {
    return part.toString();
  }
  assert(part is String);
  var partText = part as String;

  /// Look like an int
  var intValue = int.tryParse(partText);
  if (intValue != null) {
    return '"$partText"';
  }

  return partText;
}

Object _keyPartFromString(String partText) {
  if (partText.startsWith('"') && partText.endsWith('"')) {
    return partText.substring(1, partText.length - 1);
  }
  var intValue = int.tryParse(partText);
  if (intValue is int) {
    return intValue;
  }
  return partText;
}

/// Convert ['key1', 'key2', index3, 'key4] to 'key1.key2.index3.key4'
/// string representing are double quoted (i.e. "1")
/// part with a dot are not supported yet...
String keyPartsToString(List<Object> parts) {
  return parts.map(_keyPartToString).join('.');
}

/// Convert 'key1.key2.index3.key4' to ['key1', 'key2', index3, 'key4]
List<Object> keyPartsFromString(String key) {
  return key.split('.').map(_keyPartFromString).toList();
}

/// Get raw value helper for map and list - internal
T? rawGetKeyPathValue<T extends Object?>(Object rawValue, List<Object> parts) {
  if (parts.isEmpty) {
    return rawValue.anyAs<T?>();
  } else if (rawValue is Map) {
    return rawValue.getKeyPathValue<T>(parts);
  } else if (rawValue is List) {
    return rawValue.getKeyPathValue<T>(parts);
  }
  return null;
}

/// Convenient extension on Model
extension ModelRawMapExt on Map {
  /// Get a map entry for a given key. Returns null if it does not exists
  ///
  /// slow implementation for null value
  /// could be overriden by implementation
  ModelEntry? getMapEntry(String key) {
    dynamic value = this[key];
    if (value == null) {
      if (!containsKey(key)) {
        return null;
      }
    }
    return MapEntry(key, value);
  }

  /// Set a value, remove the key if [value] is null and [presentIfNull]
  /// is false.
  void setValue<T extends Object?>(
    K key,
    T value, {
    bool presentIfNull = false,
  }) {
    if (value == null && (!presentIfNull)) {
      remove(key);
    } else {
      this[key] = value;
    }
  }

  /// ['key1', 'key2', index3, 'key4]
  T? getKeyPathValue<T extends Object?>(List<Object> parts) {
    var path = parts.first;
    var rawValue = this[path] as Object?;
    if (rawValue == null) {
      return null;
    }
    return rawGetKeyPathValue(rawValue, parts.sublist(1));
  }

  /// Get a value expecting a given type
  T? getValue<T extends Object?>(String key) => this[key] as T?;

  /// Override the map with a value from a field or from a value.
  ///
  /// Not set if value is null and field value not set.
  void cvOverride(CvField field, [Object? value]) {
    if (value != null || field.hasValue) {
      this[field.k] = value ?? field.v;
    }
  }

  /// Nullify a field.
  void cvSetNull(CvField field) {
    this[field.k] = null;
  }

  /// Remove a field.
  void cvRemove(CvField field) => remove(field.k);

  /// Cast the map if needed.
  Model asModel() => cvimpl.asModel(this);

  /// Clone as a model.
  Model deepClone() {
    var model = newModel();
    for (var anyKey in keys) {
      var key = anyKey.toString();
      var value = this[key];
      if (value is Map) {
        model[key] = value.deepClone();
      } else if (value is List) {
        model[key] = value.deepClone();
      } else {
        model[key] = value;
      }
    }
    return model;
  }
}
