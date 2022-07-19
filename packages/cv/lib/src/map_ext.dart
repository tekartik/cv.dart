import 'package:cv/cv.dart';
import 'package:cv/src/typedefs.dart';

/// Convenient extension on Model
extension ModelExt on Model {
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
  void setValue<T>(K key, T value, {bool presentIfNull = false}) {
    if (value == null && (!presentIfNull)) {
      remove(key);
    } else {
      this[key] = value;
    }
  }

  /// Get a value expecting a given type
  T? getValue<T>(String key) => this[key] as T?;

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
}
