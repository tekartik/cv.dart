import 'dart:collection';

import 'package:cv/cv.dart';
import 'package:cv/src/cv_field_with_parent.dart';

import 'column.dart';

/// CvField access
///
/// Use [v] for value access.
abstract class CvFieldCore<T> implements CvColumn<T> {
  /// The value (abbr.)
  T? get v;

  /// The value
  T? get value;

  /// The key (abbr.)
  String get k;

  /// The key
  String get key;

  /// Return true is null or unset
  bool get isNull;

  /// Set the value, even if null
  set v(T? value);

  /// Set the value, even if null.
  set value(T? value);

  /// Clear value and flag
  void clear();

  // to be deprecated use clear instead
  @deprecated
  void removeValue();

  /// [presentIfNull] true if null is marked as a value
  void setValue(T? value, {bool presentIfNull = false});

  bool get hasValue;

  /// Allow dynamic CvFields, copy if the value if set, otherwise delete it
  void fromCvField(CvField cvField);

  /// Cast if needed
  CvField<RT> cast<RT>();

  /// Force the null value.
  void setNull();

  /// Make the field an inner field, the parent being a map
  CvField<T> withParent(String parent);
}

/// Base for sub model or list of models
abstract class CvModelFieldCreator<T extends CvModel> {
  /// contentValue should be ignored or could be used to create the proper object
  /// but its content should not be populated.
  T create(Map contentValue);
}

/// Nested CvField content
abstract class CvFieldContent<T extends CvModel>
    implements CvField<T>, CvModelFieldCreator<T> {
  /// Only set value if not null
  factory CvFieldContent(
          String name, T Function(dynamic contentValue) create) =>
      CvFieldContentImpl(name, create);
}

/// Nested list
abstract class CvFieldContentList<T extends CvModel>
    implements CvField<List<T>>, CvModelFieldCreator<T> {
  List<T> createList();

  /// Only set value if not null
  factory CvFieldContentList(
          String name, T Function(dynamic contentValue) create) =>
      CvFieldContentListImpl(name, create);
}

class _List<T> extends ListBase<T> {
  final _list = <T?>[];

  @override
  void add(T element) {
    _list.add(element);
  }

  @override
  int get length => _list.length;

  @override
  T operator [](int index) {
    return _list[index]!;
  }

  @override
  void operator []=(int index, T value) {
    _list[index] = value;
  }

  @override
  set length(int newLength) => _list.length = newLength;
}

/// Nested list implementation.
class ListCvFieldImpl<T> extends CvFieldImpl<List<T>>
    implements CvField<List<T>>, CvListField<T> {
  @override
  List<T> createList() => _List<T>();

  ListCvFieldImpl(String name) : super(name);

  @override
  Type get itemType => T;
}

/// Content creator mixin
mixin CvFieldContentCreatorMixin<T extends CvModel>
    implements CvModelFieldCreator<T> {
  T Function(Map contentValue)? _create;

  @override
  T create(Map contentValue) =>
      _create != null ? _create!(contentValue) : cvBuildModel<T>(contentValue);
}

/// Nested list of object implementation.
class CvFieldContentListImpl<T extends CvModel> extends CvFieldImpl<List<T>>
    with CvFieldContentCreatorMixin<T>
    implements CvFieldContentList<T>, CvModelListField<T> {
  @override
  List<T> createList() => _List<T>();

  CvFieldContentListImpl(
      String name, T Function(Map contentValue)? createObjectFn)
      : super(name) {
    _create = createObjectFn;
  }

  @override
  Type get itemType => T;
}

class CvFieldContentImpl<T extends CvModel> extends CvFieldImpl<T>
    with CvFieldContentCreatorMixin<T>
    implements CvFieldContent<T>, CvModelField<T> {
  CvFieldContentImpl(String name, T Function(Map contentValue)? createObjectFn)
      : super(name) {
    _create = createObjectFn;
  }
}

class CvFieldImpl<T>
    with // order is important, 2020/11/08 last one wins!
        CvColumnMixin<T>,
        ColumnNameMixin,
        CvFieldMixin<T> {
  /// Only set value if not null
  CvFieldImpl(String name, [T? value]) {
    this.name = name;
    if (value != null) {
      v = value;
    }
  }

  /// Force a null value
  CvFieldImpl.withNull(String name) {
    this.name = name;
    _hasValue = true;
  }

  /// Set value even if null
  CvFieldImpl.withValue(String name, T value) {
    this.name = name;
    v = value;
  }
}

// ensure mixin compiles
// ignore: unused_element
class _TestCvField
    with ColumnNameMixin, CvColumnMixin, CvFieldMixin
    implements CvField {}

mixin CvFieldMixin<T> implements CvField<T> {
  T? _value;

  /// The value
  @override
  T? get v => _value;

  @override
  String get key => name;

  @override
  T? get value => _value;

  /// The key
  @override
  String get k => name;

  @override
  bool get isNull => _value == null;

  @override
  set v(T? value) {
    _hasValue = true;
    _value = value;
  }

  @override
  set value(T? value) => v = value;

  /// Clear value and flag
  @override
  void clear() {
    _value = null;
    _hasValue = false;
  }

  // to be deprecated use clear instead
  @override
  @deprecated
  void removeValue() {
    _value = null;
    _hasValue = false;
  }

  /// [presentIfNull] true if null is marked as a value
  @override
  void setValue(T? value, {bool presentIfNull = false}) {
    if (value == null) {
      if (presentIfNull) {
        v = value;
      } else {
        clear();
      }
    } else {
      v = value;
    }
  }

  bool _hasValue = false;

  @override
  bool get hasValue => _hasValue;

  /// Allow dynamic CvFields
  @override
  void fromCvField(CvField cvField) {
    if (cvField.v is T?) {
      setValue(cvField.v as T?, presentIfNull: cvField.hasValue);
    } else if (isTypeString && cvField.hasValue) {
      /// To string conversion
      setValue(cvField.v?.toString() as T?, presentIfNull: true);
    }
  }

  @override
  String toString() => '$name: $v${(v == null && hasValue) ? ' (set)' : ''}';

  /// Cast if needed
  @override
  CvField<RT> cast<RT>() {
    if (this is CvField<RT>) {
      return this as CvField<RT>;
    }
    return CvField<RT>(name)..v = v as RT?;
  }

  @override
  int get hashCode => key.hashCode + (v?.hashCode ?? 0);

  @override
  bool operator ==(other) {
    if (other is CvField) {
      if (other.name != name) {
        return false;
      }
      if (other.hasValue != hasValue) {
        return false;
      }
      if (!cvValuesAreEqual(other.v, v)) {
        return false;
      }
      return true;
    }
    return false;
  }

  /// Force the null value.
  @override
  void setNull() {
    setValue(null, presentIfNull: true);
  }

  @override
  CvField<T> withParent(String parent) => CvFieldWithParentImpl(this, parent);
}

/// List<Column> helpers
extension CvColumnExtension on List<CvColumn> {
  List<String> get names => map((c) => c.name).toList();
}
