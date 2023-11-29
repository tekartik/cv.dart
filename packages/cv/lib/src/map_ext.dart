import 'package:cv/cv.dart';
import 'package:cv/cv.dart' as cvimpl;
import 'package:cv/src/typedefs.dart';

/// Get raw value helper for map and list.
T? rawGetKeyPathValue<T extends Object?>(Object? rawValue, List<Object> paths) {
  if (paths.isEmpty) {
    if (rawValue is T) {
      return rawValue;
    }
    return null;
  } else if (rawValue is Map) {
    return rawValue.getKeyPathValue<T>(paths);
  } else if (rawValue is List) {
    return rawValue.getKeyPathValue<T>(paths);
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
  void setValue<T extends Object?>(K key, T value,
      {bool presentIfNull = false}) {
    if (value == null && (!presentIfNull)) {
      remove(key);
    } else {
      this[key] = value;
    }
  }

  /// ['key1', 'key2', index3, 'key4]
  T? getKeyPathValue<T extends Object?>(List<Object> paths) {
    Object? rawValue;
    var path = paths.first;
    for (var entry in entries) {
      if (entry.key == path) {
        rawValue = entry.value;
        return rawGetKeyPathValue(rawValue, paths.sublist(1));
      }
    }
    return null;
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
}
