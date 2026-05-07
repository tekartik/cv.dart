import 'package:cv/cv.dart';
import 'package:cv/utils/value_utils.dart';
import 'cv_field.dart';
import 'cv_multi_field.dart';
import 'field.dart';

/// Value access is prohibited here, to set last
/// used in MultiField
mixin CvFieldNoValueAccessMixin<T extends Object?> implements CvFieldCore<T> {
  @override
  T? get value =>
      throw StateError('Cannot read value from a CvFieldNoValueAccessMixin');
}

/// Private helpers
extension CvListFieldPrvExt<T extends Object?> on CvListField<T> {
  /// list value from any value
  Object? listValueFromRawValue(Object? value) {
    if (value != null) {
      var field = this;

      if (field is CvFieldContentList) {
        if (value is Map) {
          var item = (field as CvFieldContentList).create(value)
            ..fromMap(value);
          return item;
        }
      } else if (field is ListCvFieldImpl &&
          typeMatchesBasicType(field.itemType, value)) {
        /// Only replace
        return basicTypeCastType(field.itemType, value);
      } else if (field is CvListField<Map> && value is Map) {
        return value;
      } else if (field is CvListField<List> && value is List) {
        return value;
      }
    }
    return null;
  }
}

/// Type mapping
bool typeMatchesBasicType(Type type, Object value) {
  if (type == bool) {
    return value is bool;
  } else if (type == int) {
    return value is num;
  } else if (type == double) {
    return value is num;
  } else if (type == num) {
    return value is num;
  } else if (type == String) {
    return value is String;
  }
  return false;
}

/// Private extension
extension CvFieldMixinExtPrv on CvField {
  /// Check if a value matches the field basic type.
  bool matchesBasicType(Object value) {
    return typeMatchesBasicType(type, value);
  }

  /// Matchs type
  bool matchesType(Object value) {
    var field = this;
    if (field is CvFieldContentList) {
      return value is List;
    } else if (field is CvFieldContent) {
      return value is Map;
    } else if (field is CvListField) {
      return value is List;
    } else if (field is CvModelMapField) {
      return value is Map;
    } else if (field is CvFieldEncodedImpl) {
      return true;
    } else if (field is CvFieldImpl && field.isBasicType) {
      return matchesBasicType(value);
    } else if (field is CvMultiField) {
      if (field.multiMatchesType(value)) {
        return true;
      }
    } else if (field is CvMultiListField) {
      if (value is List) {
        return true;
      }
    }
    return false;
  }

  /// From any value
  bool fromAnyValue(Object? value) {
    return _fromAny(value);
  }

  bool _fromAny(Object? value) {
    var field = this;

    if (value != null) {
      if (field is CvFieldContentList) {
        if (value is List) {
          var list = field.v = field.createList();
          for (var rawItem in value) {
            if (rawItem is Map) {
              var item = field.create(rawItem)..fromMap(rawItem);
              list.add(item);
            }
          }
          field.v = list;
          return true;
        }
      } else if (field is CvFieldContent) {
        if (value is Map) {
          var entryValue = value;
          var cvModel = field.create(entryValue);
          field.v = cvModel;
          cvModel.fromMap(entryValue);
          return true;
        }
      } else if (field is CvListField) {
        if (value is List) {
          if (field.isBasicItemType) {
            field.fromBasicTypeValueList(value);
          } else {
            var list = field.v = field.createList();
            for (var rawItem in value) {
              list.add(rawItem);
            }
          }
          return true;
        }
      } else if (field is CvModelMapField) {
        if (value is Map) {
          var map = field.v = field.createMap();
          var entryValue = value;
          entryValue.forEach((key, value) {
            var item = field.create(value as Map)..fromMap(value);
            map[key as String] = item;
          });
          return true;
        }
      } else if (field is CvFieldEncodedImpl) {
        // Decode
        Object? decodedValue;
        var encodedValue = value;
        if (field.codec != null) {
          decodedValue = field.codec!.decode(encodedValue);
        } else {
          decodedValue = encodedValue;
        }
        field.v = decodedValue;
        return true;
      } else if (field is CvFieldImpl && field.isBasicType) {
        /// Only replace
        field.fromBasicTypeValue(value, presentIfNull: true);
        return true;
      } else if (field is CvMultiField) {
        field.multiFromAnyValue(value);

        return true;
      } else if (field is CvMultiListField) {
        if (value is List) {
          field.multiFromAnyList(value);
          return true;
        }
      } else {
        try {
          field.v = value;
        } catch (_) {
          // Special string handling
          if (field.type == String) {
            field.v = value.toString();
          } else {
            rethrow;
          }
        }
      }
    } else {
      field.setNull();
      return true;
    }
    return false;
  }
}
