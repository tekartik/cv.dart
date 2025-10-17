import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:cv/cv.dart';
import 'package:cv/src/cv_field_with_parent.dart';
import 'package:cv/src/date_time.dart';
import 'package:cv/utils/value_utils.dart';

import 'builder.dart';
import 'column.dart';
import 'enum.dart';
import 'field.dart';

/// Common fill options for unit tests.
CvFillOptions get cvFillOptions1 =>
    CvFillOptions(valueStart: 0, collectionSize: 1);

/// If 2 values are equals, entering nested list/map if any.
bool cvValuesAreEqual(dynamic v1, dynamic v2) {
  try {
    return const DeepCollectionEquality().equals(v1, v2);
  } catch (_) {
    return v1 == v2;
  }
}

/// Basic CvField
abstract class CvField<T extends Object?> implements CvFieldCore<T> {
  /// Only set value if not null
  factory CvField(String name, [T? value]) => CvFieldImpl(name, value);

  /// Enum field, give a name and a list of possible values (such as `MyEnum.values`)
  static CvField<T> encodedEnum<T extends Enum>(String name, List<T> values) =>
      encoded<T, String>(name, codec: EnumToStringCodec<T>(values));

  /// Enum field, give a name and a list of possible values (such as `MyEnum.values`)
  static CvField<DateTime> encodedDateTime(String name) =>
      encoded<DateTime, String>(name, codec: const DateTimeToStringCodec());

  /// Force a null value
  factory CvField.withNull(String name) => CvFieldImpl.withNull(name);

  /// Force a value even if null
  factory CvField.withValue(String name, T? value) =>
      CvFieldImpl.withValue(name, value);

  /// Encode a [S] source exposed value to an encoded [T] saved value
  static CvField<S> encoded<S extends Object?, T extends Object?>(
    String name, {
    required Codec<S, T>? codec,
  }) {
    var encryptedField = CvField<T>(name);
    return CvFieldEncodedImpl<S, T>(name, encryptedField, codec);
  }
}

/// Transform helper.
class CvFieldEncodedImpl<S extends Object?, T extends Object?>
    with
        CvColumnMixin<S>,
        ColumnNameMixin,
        CvFieldHelperMixin<S>,
        CvFieldMixin<S>
    implements CvField<S> {
  /// Source field.
  final CvField<T> encodedField;

  /// Codec.
  final Codec<S, T>? codec;

  /// Transform helper.
  CvFieldEncodedImpl(String name, this.encodedField, this.codec) {
    this.name = name;
  }
}

/// Nested list of raw values
abstract class CvListField<T extends Object?> implements CvField<List<T>> {
  /// List create helper
  List<T> createList();

  /// List item type
  Type get itemType;

  /// Only set value if not null
  factory CvListField(String name) => ListCvFieldImpl<T>(name);
}

void _fillModel(CvModel model, CvFillOptions options) {
  var usedTypes = options.usedTypes;
  if (!(usedTypes?.contains(model.runtimeType) ?? false)) {
    var newOptions = options.copyWith(
      usedTypes: {if (usedTypes != null) ...usedTypes, model.runtimeType},
    );
    model.fillModel(newOptions);
    options.valueStart = newOptions.valueStart;
  }
}

/// Field utils.
extension CvFieldUtilsExt<T extends Object?> on CvField<T> {
  /// For test
  void fillField([CvFillOptions? options]) {
    options ??= CvFillOptions();
    if (this is CvListField) {
      (this as CvListField).fillList(options);
    } else if (this is CvModelMapField) {
      (this as CvModelMapField).fillMap(options);
    } else if (this is CvModelField) {
      var modelValue = (this as CvModelField).create({});
      _fillModel(modelValue, options);

      v = modelValue as T;
    } else if (this is CvFieldWithParent) {
      (this as CvFieldWithParent).field.fillField(options);
    } else if (options.valueStart != null) {
      if (cvTypeGetBuilderOrNull(type) != null) {
        throw UnsupportedError(
          '$this should likely be a CvModelField<$type> rather than CvField<$type> right?',
        );
      }
      v = options.generateValue(type) as T;
    } else {
      // Default to null
      v = null;
    }
  }

  /// Create a new field with a new name
  CvField<T> withName(String name) => CvField<T>(name, value);

  /// Only for String/bool/num/int/double
  void fromBasicTypeValue(Object? value, {bool presentIfNull = false}) {
    if (value == null && presentIfNull) {
      setValue(value as T?, presentIfNull: true);
    } else {
      var fixedValue = basicTypeCastType(type, value);
      if (fixedValue != null) {
        setValue(fixedValue as T);
      }
    }
  }

  /// Check if the field is a basic type (num, String, bool, int, double)
  bool get isBasicType => type.isBasicType;
}

/// Generate for bool, int, num, text
Object? cvFillOptionsGenerateBasicType(Type type, CvFillOptions options) {
  late int valueStart;

  Object? v;
  if (options.valueStart != null) {
    valueStart = options.valueStart! + 1;
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
    } else if (type == List) {
      options.valueStart = valueStart - 1;
      v = options.generateList();
      valueStart = options.valueStart!;
    } else if (type == Map || type == Model) {
      options.valueStart = valueStart - 1;
      v = options.generateMap();
      valueStart = options.valueStart!;
    }
    if (v != null) {
      options.valueStart = valueStart;
    }
  }

  return v;
}

/// Test fill generator function definition.
typedef CvFillOptionsGenerateFunction =
    Object? Function(Type type, CvFillOptions options);

/// Fill options for unit tests must be created each time as it handles recursion.
class CvFillOptions {
  /// Default collection size. If nul no collections
  final int? collectionSize;

  /// fill value start. If null fill with null.
  int? valueStart;

  /// Generator function.
  final CvFillOptionsGenerateFunction? generate;

  /// Used types to avoid recursion.
  Set<Type>? usedTypes;

  /// Generate a value.
  Object? generateValue(Type type) => (generate == null)
      ? cvFillOptionsGenerateBasicType(type, this)
      : (generate!(type, this) ?? cvFillOptionsGenerateBasicType(type, this));

  /// Fill options.
  CvFillOptions({
    this.collectionSize,
    this.valueStart,
    this.generate,
    this.usedTypes,
  });

  /// Copy fill options.
  CvFillOptions copyWith({
    int? collectionSize,
    int? valueStart,
    CvFillOptionsGenerateFunction? generate,
    Set<Type>? usedTypes,
  }) {
    return CvFillOptions(
      collectionSize: collectionSize ?? this.collectionSize,
      valueStart: valueStart ?? this.valueStart,
      generate: generate ?? this.generate,
      usedTypes: usedTypes ?? this.usedTypes,
    );
  }
}

extension _CvFillOptionsExt on CvFillOptions {
  /// Generate a basic map
  Model generateMap({Object Function()? generateMapValue}) {
    var map = newModel();
    var size = collectionSize ?? 0;
    for (var i = 0; i < size; i++) {
      map['field_${i + 1}'] = generateMapValue != null
          ? generateMapValue()
          : generateValue(int);
    }
    return map;
  }

  /// Generate a basic list
  List generateList() {
    var list = <Object?>[];
    var size = collectionSize ?? 0;
    for (var i = 0; i < size; i++) {
      list.add(generateValue(int));
    }
    return list;
  }
}

/// Fill helpers
extension CvListFieldUtilsExt<T extends Object?> on CvListField<T> {
  /// Fill a list.
  void fillList([CvFillOptions? options]) {
    options ??= CvFillOptions();
    var collectionSize = options.collectionSize;
    if (collectionSize == null) {
      value = null;
    } else {
      var list = createList();
      for (var i = 0; i < collectionSize; i++) {
        if (this is CvModelListField) {
          var item = (this as CvModelListField).create({}) as T;
          _fillModel(item as CvModel, options);
          list.add(item);
        } else if (this is CvListField<Map>) {
          if (options.valueStart != null) {
            list.add(options.generateMap() as T);
          }
        } else if (this is CvListField<List>) {
          if (options.valueStart != null) {
            // print('list $this');
            list.add(options.generateList() as T);
          }
        } else {
          if (options.valueStart != null) {
            // print('item $this');
            list.add(options.generateValue(itemType) as T);
          }
        }
      }
      value = list;
    }
  }

  /// Only for String/bool/num/int/double
  void fromBasicTypeValueList(Object? value, {bool presentIfNull = false}) {
    if (value is List) {
      var list = createList();
      for (var rawItem in value) {
        var item = basicTypeCastType(itemType, rawItem);
        if (item is T) {
          list.add(item);
        }
      }
      setValue(list);
    } else {
      if (presentIfNull) {
        setValue(null, presentIfNull: true);
      }
    }
  }

  /// Check if the field is a basic type (num, String, bool, int, double)
  bool get isBasicItemType => itemType.isBasicType;
}

/// Fill helpers
extension CvModelMapFieldUtilsExt<T extends CvModel> on CvModelMapField<T> {
  /// Fill a list.
  void fillMap([CvFillOptions? options]) {
    options ??= CvFillOptions();
    var collectionSize = options.collectionSize;
    if (collectionSize == null) {
      value = null;
    } else {
      var rawMap = options.generateMap(
        generateMapValue: () {
          var item = create({});
          _fillModel(item, options!);

          return item;
        },
      );
      var map = createMap();
      rawMap.forEach((key, value) {
        map[key] = value as T;
      });

      value = map;
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
    _fillModel(value as CvModel, options);
  }
}

/// Nested model
abstract class CvModelField<T extends CvModel> implements CvField<T> {
  /// contentValue should be ignored
  T create(Map contentValue);

  /// Only set value if not null
  factory CvModelField(
    String name, [
    // Arg... I want to deprecate this... please use builder instead
    // @Deprecated('Use CvModelField.builder() instead')
    T Function(dynamic contentValue)? create,
  ]) => CvFieldContentImpl<T>(name, create);

  /// Only set value if not null, optional builder method
  factory CvModelField.builder(
    String name, {
    CvModelBuilderFunction<T>? builder,
  }) => CvFieldContentImpl<T>(name, builder);
}

/// Utilities
extension CvFieldListExt on CvFields {
  /// Return fields matching columns.
  CvFields matchingColumns(List<String>? columns) {
    if (columns == null) {
      return this;
    }
    return where((element) => columns.contains(element.name)).toList();
  }

  /// Return field matching column.
  CvField? matchingColumn(String column) {
    return firstWhereOrNull((element) => element.name == column);
  }

  /// Copy all fields
  void fromCvFields(CvFields fields) {
    assert(length == fields.length);
    for (var i = 0; i < length; i++) {
      this[i].fromCvField(fields[i]);
    }
  }

  /// Return the column names.
  List<String> get columns => map((field) => field.name).toList();
}

/// Nested list, where each value is of type T
abstract class CvModelListField<T extends CvModel> implements CvListField<T> {
  /// contentValue should be ignored or could be used to create the proper object
  /// but its content should not be populated.
  T create(Map contentValue);

  @override
  List<T> createList();

  /// Only set value if not null
  factory CvModelListField(
    String name, [
    // Soon to be deprecated
    // @Deprecated('User CvModelListField.builder() instead')
    T Function(dynamic contentValue)? create,
  ]) => CvFieldContentListImpl<T>(name, create);

  /// Only set value if not null, optional builder method
  factory CvModelListField.builder(
    String name, {
    CvModelBuilderFunction<T>? builder,
  }) => CvFieldContentListImpl<T>(name, builder);
}

/// Nested map where each value is of type T, (key is a string)
abstract class CvModelMapField<T extends CvModel>
    extends CvField<Map<String, T>> {
  /// contentValue should be ignored or could be used to create the proper object
  /// but its content should not be populated.
  T create(Map contentValue);

  /// Create the proper map
  Map<String, T> createMap();

  /// Only set value if not null
  factory CvModelMapField(String name) => CvFieldContentMapImpl<T>(name, null);

  /// Only set value if not null, optional builder method
  factory CvModelMapField.builder(
    String name, {
    CvModelBuilderFunction<T>? builder,
  }) => CvFieldContentMapImpl<T>(name, builder);
}

/// Generic fields type helper for model fields value.
typedef CvFields = List<CvField<Object?>>;
