import 'package:collection/collection.dart';
import 'package:cv/cv.dart';
import 'package:cv/src/cv_field_with_parent.dart';

import 'cv_model.dart';
import 'field.dart';

/// If 2 values are equals, entering nested list/map if any.
bool cvValuesAreEqual(dynamic v1, dynamic v2) {
  try {
    return DeepCollectionEquality().equals(v1, v2);
  } catch (_) {
    return v1 == v2;
  }
}

/// Basic CvField
abstract class CvField<T> implements CvFieldCore<T> {
  /// Only set value if not null
  factory CvField(String name, [T? value]) => CvFieldImpl(name, value);

  /// Force a null value
  factory CvField.withNull(String name) => CvFieldImpl.withNull(name);

  /// Force a value event if null
  factory CvField.withValue(String name, T value) =>
      CvFieldImpl.withValue(name, value);
}

/// Nested list of raw values
abstract class CvListField<T> implements CvField<List<T>> {
  /// List create helper
  List<T> createList();

  /// List item type
  Type get itemType;

  /// Only set value if not null
  factory CvListField(String name) => ListCvFieldImpl<T>(name);
}

/// Field utils.
extension CvFieldUtilsExt<T> on CvField<T> {
  /// For test
  void fillField([CvFillOptions? options]) {
    options ??= CvFillOptions();
    if (this is CvListField) {
      (this as CvListField).fillList(options);
    } else if (this is CvModelField) {
      var modelValue = (this as CvModelField).create({})..fillModel(options);
      setValue(modelValue as T?);
    } else if (this is CvFieldWithParent) {
      (this as CvFieldWithParent).field.fillField(options);
    } else if (options.valueStart != null) {
      setValue(options.generateValue(type) as T?);
    } else {
      // Default to null
      setNull();
    }
  }

  /// Create a new field with a new name
  CvField<T> withName(String name) => CvField<T>(name, value);
}

/// Generate for bool, int, num, text
Object? cvFillOptionsGenerateBasicType(Type type, CvFillOptions options) {
  Object? v;
  if (options.valueStart != null) {
    var valueStart = options.valueStart! + 1;
    if (type == int) {
      v = valueStart;
    } else if (type == num) {
      v = valueStart.isEven ? valueStart : (valueStart + .5);
    } else if (type == double) {
      v = (valueStart + .5);
    } else if (type == String) {
      v = 'text_$valueStart';
    } else if (type == bool) {
      v = valueStart.isEven;
    }
    if (v != null) {
      options.valueStart = valueStart;
    }
  }

  return v;
}

/// Test fill generator function definition.
typedef CvFillOptionsGenerateFunction = Object? Function(
    Type type, CvFillOptions options);

/// Fill options for unit tests
class CvFillOptions {
  /// Default collection size. If nul no collections
  final int? collectionSize;

  /// fill value start. If null fill with null.
  int? valueStart;

  /// Generator function.
  final CvFillOptionsGenerateFunction? generate;

  /// Generate a value.
  Object? generateValue(Type type) => (generate == null)
      ? cvFillOptionsGenerateBasicType(type, this)
      : (generate!(type, this) ?? cvFillOptionsGenerateBasicType(type, this));

  /// Fill options.
  CvFillOptions({this.collectionSize, this.valueStart, this.generate});
}

/// Fill helpers
extension CvListFieldUtilsExt<T> on CvListField<T> {
  /// Fill a list.
  void fillList([CvFillOptions? options]) {
    options ??= CvFillOptions();
    var collectionSize = options.collectionSize;
    if (collectionSize == null) {
      setNull();
    } else {
      var list = createList();
      for (var i = 0; i < collectionSize; i++) {
        if (this is CvModelListField) {
          var item = (this as CvModelListField).create({}) as T;
          (item as CvModel).fillModel(options);
          list.add(item);
        } else if (this is CvListField<Map>) {
          if (options.valueStart != null) {
            print('map $this');
            var map = <String, Object?>{};
            for (var i = 0; i < collectionSize; i++) {
              map['field_$i'] = options.generateValue(int);
            }
            list.add(map as T);
          }
        } else if (this is CvListField<List>) {
          if (options.valueStart != null) {
            print('list $this');
            var subList = <Object?>[];
            for (var i = 0; i < collectionSize; i++) {
              subList.add(options.generateValue(int));
            }
            list.add(subList as T);
          }
        } else {
          if (options.valueStart != null) {
            print('item $this');
            list.add(options.generateValue(itemType) as T);
          }
        }
      }
      value = list;
    }
  }
}

/// Field extension utilities
extension CvModelFieldUtilsExt<T extends CvModel> on CvModelField<T> {
  /// Fill all null in model including leaves
  ///
  /// Fill list if listSize is set
  ///
  void fillModel([CvFillOptions? options]) {
    options ??= CvFillOptions();
    value = create({});
    value.fillModel(options);
  }
}

/// Nested model
abstract class CvModelField<T extends CvModel> implements CvField<T> {
  /// contentValue should be ignored
  T create(Map contentValue);

  /// Only set value if not null
  factory CvModelField(String name,
          [T Function(dynamic contentValue)? create]) =>
      CvFieldContentImpl<T>(name, create);
}

/// Utilities
extension CvFieldListExt on List<CvField> {
  /// Copy all fields
  void fromCvFields(List<CvField> fields) {
    assert(length == fields.length);
    for (var i = 0; i < length; i++) {
      this[i].fromCvField(fields[i]);
    }
  }
}

/// Nested list
abstract class CvModelListField<T extends CvModel> implements CvListField<T> {
  /// contentValue should be ignored or could be used to create the proper object
  /// but its content should not be populated.
  T create(Map contentValue);

  @override
  List<T> createList();

  /// Only set value if not null
  factory CvModelListField(String name,
          [T Function(dynamic contentValue)? create]) =>
      CvFieldContentListImpl<T>(name, create);
}
