import 'dart:collection';

import 'package:cv/cv.dart';
import 'package:cv/src/column.dart';
import 'package:cv/src/cv_model.dart';
import 'package:cv/src/typedefs.dart';

import 'cv_model_mixin.dart';
import 'field.dart';

/// Content value base implementation
///
/// Protected implementation
abstract class CvBase
    with
        // Order is important, first one wins
        ContentValuesMapMixin,
        ConventValuesKeysFromCvFieldsMixin,
        CvModelMixin,
        MapMixin<String, Object?> {}

/// Raw content value
abstract class ContentValues implements Map<K, V>, CvMapModel {
  /// Map based content values
  factory ContentValues() => ContentValuesMap();

  /// Content value with defined fields
  factory ContentValues.withCvFields(CvFields fields) {
    return _ContentValuesWithCvFields(fields);
  }
}

/// CvField in the map base implementation
class _ContentValuesMapField<T extends Object?>
    with
        CvColumnMixin<T>,
        ColumnNameMixin,
        CvFieldHelperMixin<T>,
        CvFieldMixin<T>
    implements CvField<T> {
  /// Content values (this holder)
  final ContentValues cv;

  /// Only set value if not null
  _ContentValuesMapField(this.cv, String name, [T? value]) {
    this.name = name;
    setValue(value);
  }

  /// Only set value if not null
  _ContentValuesMapField.noSet(this.cv, String name) {
    this.name = name;
  }

  /// Force a null value
  _ContentValuesMapField.withNull(this.cv, String name) {
    this.name = name;
    setNull();
  }

  @override
  T? get valueOrNull => cv.getMapValue(name) as T?;

  @override
  CvField<RT> cast<RT>() =>
      T == RT ? this as CvField<RT> : _ContentValuesMapField<RT>(cv, name);

  @override
  void clear() => cv.remove(name);

  @override
  void fromCvField(CvField cvField) {
    // copy the value whatever the name is
    if (cvField.hasValue) {
      cv[name] = cvField.v;
    } else {
      cv.remove(name);
    }
  }

  @override
  bool get hasValue => cv.containsKey(name);

  @override
  bool get isNull => cv[name] == null;

  @override
  void setNull() {
    cv[name] = null;
  }

  @override
  void setValue(value, {bool presentIfNull = false}) {
    if (value != null) {
      cv[name] = value;
    } else if (presentIfNull) {
      cv[name] = null;
    } else {
      cv.remove(name);
    }
  }

  @override
  set valueOrNull(T? value) {
    cv[name] = value;
  }
}

/// Map model base mixin
mixin MapModelBaseMixin implements Model {
  late Map<String, dynamic> _map;

  @override
  Object? operator [](Object? key) => getMapValue(key as String);

  @override
  void operator []=(String key, value) => setMapValue(key, value);

  @override
  void clear() => clearMap();

  @override
  Iterable<String> get keys => getMapKeys();

  @override
  dynamic remove(Object? key) => mapRemove(key as String);
}

/// Private extension
extension MapModelBaseMixinExtPrv on MapModelBaseMixin {
  /// Initialize the map
  void initMap([Map<String, Object?>? map]) {
    _map = map ?? <String, Object?>{};
  }

  /// Set a map value
  void setMapValue(String key, Object? value) {
    _map[key] = value;
  }

  /// Clear the map
  void clearMap() {
    _map.clear();
  }

  ///
  Object? mapRemove(String key) {
    return _map.remove(key);
  }

  /// Set a map value
  Object? getMapValue(String key) {
    return _map[key];
  }

  /// Get the map keys
  Iterable<String> getMapKeys() => _map.keys;
}

/// Private extension
extension ContentValuesPrv on ContentValues {
  /// Set a map value
  Object? getMapValue(String key) {
    return (this as MapModelBaseMixin).getMapValue(key);
  }

  /// Field in the map model, generated if needed
  CvField<T>? mapModelField<T extends Object?>(String name) {
    var value = getMapValue(name);
    if (value != null) {
      return _ContentValuesMapField.noSet(this, name);
    } else {
      if (containsKey(name)) {
        return _ContentValuesMapField.noSet(this, name);
      }
    }
    return null;
  }
}

// ignore: unused_element
class _TestClass with MapModelBaseMixin, MapMixin<String, Object?> {}

/// A Map based implementation. Default implementation for content values
class ContentValuesMap
    with
        // Order is important, first one wins
        CvModelMixin,
        MapModelBaseMixin,
        MapMixin<String, Object?> //ContentValuesMapMixin
    implements ContentValues {
  /// Content value map.
  ContentValuesMap([Map<String, Object?>? map]) {
    initMap(map);
  }

  @override
  CvFields get fields => keys
      .map((name) => field<Object?>(name)!)
      //.where((field) => field != null)
      .toList();

  @override
  CvField<T>? field<T extends Object?>(String name) {
    var value = this[name];
    if (value != null) {
      return _ContentValuesMapField(this, name, value as T);
    } else {
      if (containsKey(name)) {
        return _ContentValuesMapField<T>.withNull(this, name);
      }
    }
    return null;
  }

  @override
  void fromMap(Map? map, {List<String>? columns}) {
    if (columns == null) {
      map!.forEach((key, value) {
        _map[key.toString()] = value;
      });
    } else {
      for (var column in columns) {
        if (map!.containsKey(column)) {
          _map[column] = map[column];
        }
      }
    }
  }
}

/// Keys from CvFields
mixin ConventValuesKeysFromCvFieldsMixin implements ContentValues {
  @override
  Iterable<String> get keys => fields.map((field) => field.name);
}

/// Content value implementation mixin
mixin ContentValuesMapMixin implements ContentValues {
  @override
  Object? operator [](Object? key) {
    if (key != null) {
      return dynamicField(key)?.v;
    } else {
      return null;
    }
  }

  @override
  void operator []=(String key, Object? value) {
    dynamicField(key)?.v = value;
  }

  @override
  void clear() {
    for (var field in fields) {
      field.clear();
    }
  }

  @override
  dynamic remove(Object? key) {
    if (key != null) {
      dynamicField(key)?.clear();
    }
  }
}

class _ContentValuesWithCvFields extends CvBase {
  @override
  final CvFields fields;

  _ContentValuesWithCvFields(this.fields);
}
