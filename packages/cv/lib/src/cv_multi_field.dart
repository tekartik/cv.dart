import 'dart:collection';

import 'package:cv/cv.dart';
import 'package:cv/src/column.dart';
import 'package:cv/src/cv_field_mixin.dart';
import 'package:cv/src/env_utils.dart';
import 'package:cv/src/field.dart';

import 'cv_value.dart';

/// A field that holds multiple values as a record.
/// Limitations:
/// - only one model
/// - only one list
/// - others are basic type
abstract class CvMultiField<T extends Object?>
    implements CvField<T>, CvMultiFieldCore {}

/// A list that holds different type of value
abstract class CvMultiListField<T extends Object?>
    implements CvField<List<T>>, CvMultiListFieldCore {}

/// Utilities
extension CvMultiFieldListUtilsCorePrvExt<T> on CvMultiListFieldCore {
  _CvMultiListFieldOverriderMixin get _impl =>
      this as _CvMultiListFieldOverriderMixin;
}

/// Utilities
extension CvMultiFieldUtilsCorePrvExt<T> on CvMultiFieldCore {
  _CvMultiFieldOverriderMixin get _impl => this as _CvMultiFieldOverriderMixin;
}

/// Utilities
extension CvMultiFieldUtilsExt<T> on CvMultiField<T> {
  /// Fill helpers
  /// Fill a list.
  void fillMulti([CvFillOptions? options]) {
    _impl.fields.first.fillField(options);
  }
}

/// Utilities
extension CvMultiListFieldUtilsExt<T> on CvMultiListField<T> {
  /// Fill helpers
  /// Fill a list.
  void fillMulti([CvFillOptions? options]) {
    var modifiedField = _impl.listFields.first..fillField(options);
    multiList = List.of(modifiedField.valueOrNull ?? []);
  }
}

/// Core behavior
abstract class CvMultiFieldCore {
  /// set content from any value
  void multiFromAnyValue(Object? value);

  /// Get the read value
  Object? get multiValue;

  /// Get the multi field set
  CvField? get multiField;
}

/// Core behavior
abstract class CvMultiListFieldCore {
  /// set content from any value
  void multiFromAnyList(List? value);

  /// Get the list of any object
  /// The list is modifiable.
  List<Object?>? get multiList;

  /// Setter
  set multiList(List<Object?> list);

  /// Setter
  void setMultiList(List<Object?>? list, {bool? presentIfNull});
}

/// A field that holds two values as a record.
abstract class CvMultiListField2<T1 extends Object?, T2 extends Object?>
    implements CvMultiListField<(T1, T2)> {
  /// Create a multi field.
  factory CvMultiListField2(
    CvField<List<T1>> field1,
    CvField<List<T2>> field2,
  ) => _CvMultiListField2<T1, T2>(field1, field2);
}

/// A field that holds two values as a record.
abstract class CvMultiField2<T1 extends Object?, T2 extends Object?>
    implements CvMultiField<(T1, T2)> {
  /// Create a multi field.
  factory CvMultiField2(CvField<T1> field1, CvField<T2> field2) =>
      _CvMultiField2<T1, T2>(field1, field2);

  /// Get field 1
  CvField<T1> get field1;

  /// Get field 2
  CvField<T2> get field2;
}

/// Top overrider
mixin _CvMultiListFieldOverriderMixin
    implements CvValueReaderCore, _CvMultiListFieldBase, CvMultiListFieldCore {
  @override
  bool get hasValue {
    return _hasValue;
  }
}

/// Top overrider
mixin _CvMultiFieldOverriderMixin
    implements CvValueReaderCore, _CvMultiFieldBase, CvMultiFieldCore {
  /// Only this flag is set
  @override
  bool get hasValue {
    return fields.any((field) => field.hasValue);
  }

  void clear() {
    for (var field in fields) {
      field.clear();
    }
  }

  @override
  CvField? get multiField =>
      fields.where((field) => field.hasValue).firstOrNull;

  @override
  Object? get multiValue => multiField?.valueOrNull;

  @override
  String toString() =>
      '$name: ${hasValue ? multiValue?.toString() : '<unset>'}';
}

abstract class _CvMultiListFieldBase extends _CvMultiFieldCoreBase
    with ColumnNameMixin
    implements CvValueReaderCore {
  _CvMultiListFieldBase(super.fields) {
    name = fields.first.name;
  }
  late final listFields = fields.cast<CvListField>();

  var _hasValue = false;
  List<Object?>? _list;
  // set content from any value
  void multiFromAnyList(List? value) {
    if (value != null) {
      var valueList = value;
      _list = valueList.map((item) {
        for (var field in listFields) {
          var itemValue = field.listValueFromRawValue(item);
          if (itemValue != null) {
            return itemValue;
          }
        }
        return null;
      }).toList();
    } else {
      _list = null;
    }
    _hasValue = true;
  }

  @override
  bool get hasValue => _hasValue;
  List<Object?>? get multiList => _list;
  set multiList(List<Object?> list) {
    _list = list;
    _hasValue = true;
  }

  void setMultiList(List<Object?>? list, {bool? presentIfNull}) {
    _list = list;
    _hasValue = list != null || (presentIfNull ?? false);
  }
}

abstract class _CvMultiFieldCoreBase {
  _CvMultiFieldCoreBase(this.fields);
  final List<CvField> fields;
}

abstract class _CvMultiFieldBase extends _CvMultiFieldCoreBase
    with ColumnNameMixin
    implements CvValueReaderCore {
  _CvMultiFieldBase(super.fields) {
    name = fields.first.name;
    if (isDebug) {
      for (var field in fields.skip(1)) {
        if (field.name != name) {
          throw ArgumentError('All fields must have the same name');
        }
      }
    }
  }
  CvField<T> field<T extends Object?>(int index) {
    return fields[index] as CvField<T>;
  }

  void multiFromAnyValue(Object? value) {
    // set the first if null
    if (value != null) {
      for (var field in fields) {
        if (field.matchesType(value)) {
          field.fromAnyValue(value);
          return;
        }
      }
    }
    // Take first by default
    fields.first.fromAnyValue(value);
  }
}

class _CvMultiField2<T1 extends Object?, T2 extends Object?>
    extends _CvMultiFieldBase
    with
        CvColumnMixin<(T1, T2)>,
        CvFieldHelperMixin<(T1, T2)>,
        CvFieldMixin<(T1, T2)>,
        CvFieldNoValueAccessMixin<(T1, T2)>,
        // last one wins
        _CvMultiFieldOverriderMixin
    implements CvMultiField2<T1, T2> {
  _CvMultiField2(CvField<T1> field1, CvField<T2> field2)
    : super([field1, field2]);

  @override
  CvField<T1> get field1 => field<T1>(0);
  @override
  CvField<T2> get field2 => field<T2>(1);
}

class _CvMultiListField2<T1 extends Object?, T2 extends Object?>
    extends _CvMultiListFieldBase
    with
        CvColumnMixin<List<(T1, T2)>>,
        CvFieldHelperMixin<List<(T1, T2)>>,
        CvFieldMixin<List<(T1, T2)>>,
        CvFieldNoValueAccessMixin<List<(T1, T2)>>,
        // last wins
        _CvMultiListFieldOverriderMixin
    implements CvMultiListField2<T1, T2> {
  _CvMultiListField2(CvField<List<T1>> field1, CvField<List<T2>> field2)
    : super([field1, field2]);
}

/// Prv extension
extension CvMultiFieldPrvExt on CvMultiFieldCore {
  /// True if the type matches any of the fields
  bool multiMatchesType(Object value) {
    return _impl.fields.any((field) => field.matchesType(value));
  }
}
