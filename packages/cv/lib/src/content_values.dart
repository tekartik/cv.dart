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
        MapMixin<String, dynamic> {}

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
class _CvMapField<T extends Object?>
    with
        CvColumnMixin<T>,
        ColumnNameMixin,
        CvFieldHelperMixin<T>,
        CvFieldMixin<T>
    implements CvField<T> {
  final ContentValues cv;

  /// Only set value if not null
  _CvMapField(this.cv, String name, [T? value]) {
    this.name = name;
    setValue(value);
  }

  /// Force a null value
  _CvMapField.withNull(this.cv, String name) {
    this.name = name;
    setNull();
  }

  @override
  T? get valueOrNull => cv[name] as T?;

  @override
  CvField<RT> cast<RT>() =>
      T == RT ? this as CvField<RT> : _CvMapField<RT>(cv, name);

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

mixin _MapBaseMixin implements Map<String, dynamic> {
  late Map<String, dynamic> _map;

  @override
  dynamic operator [](Object? key) => _map[key as String];

  @override
  void operator []=(String key, value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  dynamic remove(Object? key) => _map.remove(key);
}

// ignore: unused_element
class _TestClass with _MapBaseMixin, MapMixin<String, dynamic> {}

/// A Map based implementation. Default implementation for content values
class ContentValuesMap
    with
// Order is important, first one wins
        CvModelMixin,
        _MapBaseMixin,
        MapMixin<String, dynamic> //ContentValuesMapMixin
    implements
        ContentValues {
  /// Content value map.
  ContentValuesMap([Map<String, dynamic>? map]) {
    _map = map ?? <String, dynamic>{};
  }

  @override
  CvFields get fields => keys
      .map((name) => field<dynamic>(name)!)
      //.where((field) => field != null)
      .toList();

  @override
  CvField<T>? field<T extends Object?>(String name) {
    var value = this[name];
    if (value != null) {
      return _CvMapField(this, name, value as T);
    } else {
      if (containsKey(name)) {
        return _CvMapField<T>.withNull(this, name);
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
  dynamic operator [](Object? key) {
    if (key != null) {
      return dynamicField(key)?.v;
    } else {
      return null;
    }
  }

  @override
  void operator []=(key, value) {
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
