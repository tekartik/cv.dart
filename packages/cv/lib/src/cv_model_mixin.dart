import 'package:cv/cv.dart';
import 'package:cv/src/cv_field_with_parent.dart';
import 'package:cv/src/cv_model.dart';

import 'builder.dart';
import 'cv_field.dart';
import 'env_utils.dart';
import 'field.dart';

/// For dev only
var debugContent = false; // devWarning(true);

/// Get raw value helper for map and list.
CvField<T>? rawGetFieldAtPath<T extends Object?>(
    Object rawValue, List<Object> parts) {
  if (parts.isEmpty) {
    if (rawValue is CvField<T>) {
      return rawValue;
    }
    return null;
  }
  if (rawValue is CvModelField) {
    return rawValue.v?.fieldAtPath<T>(parts);
  } else if (rawValue is CvModelListField) {
    return rawValue.v?.fieldAtPath<T>(parts);
  } else if (rawValue is CvModel) {
    return rawValue.fieldAtPath<T>(parts);
  } else if (rawValue is List) {
    return rawValue.fieldAtPath<T>(parts);
  }
  return null;
}

/// ['key1', 'key2', index3, 'key4]
T? _rawListGetValueAtPath<T extends Object?>(
    List<Object?> list, List<Object> parts) {
  var path = parts.first;
  if (path is int && path >= 0 && list.length > path) {
    var rawValue = list[path];
    if (rawValue != null) {
      return rawGetValueAtPath(rawValue, parts.sublist(1));
    }
  }
  return null;
}

/// ['key1', 'key2', index3, 'key4]
T? _rawMapGetValueAtPath<T extends Object?>(
    Map<Object?, Object?> map, List<Object> parts) {
  var path = parts.first;
  var rawValue = map[path];
  if (rawValue != null) {
    return rawGetValueAtPath(rawValue, parts.sublist(1));
  }
  return null;
}

/// Get a value at a given path - internal, handle CvField, CvModel (toMap), `List<CvModel>` (toMapList)
/// other types are returned as is for now (this might change in the future)
T? rawGetValueAtPath<T extends Object?>(Object rawValue, List<Object> parts) {
  var value = (rawValue is CvField) ? rawValue.v : rawValue;
  if (value == null) {
    return null;
  } else if (parts.isEmpty) {
    if (value is CvModelRead) {
      return value.toMap().anyAs<T?>();
    } else if (value is List<CvModelRead>) {
      return value.toMapList().anyAs<T?>();
    } else if (value is CvModelField) {
      return value.v?.toMap().anyAs<T?>();
    }
    return value.anyAs<T?>();
  } else if (rawValue is List) {
    return _rawListGetValueAtPath(rawValue, parts);
  } else if (rawValue is Map) {
    return _rawMapGetValueAtPath(rawValue, parts);
  } else if (rawValue is CvModel) {
    return rawValue.valueAtPath<T>(parts);
  }
  return null;
}

/// Content mixin
mixin CvModelMixin implements CvModel {
  @override
  String toString() {
    try {
      return '${toMap()}';
    } catch (e) {
      return '$fields $e';
    }
  }

  // Only created if necessary
  Map<String, CvField>? _cvFieldMap;

  @override
  CvField<T>? field<T extends Object?>(String name) {
    // Invalidate if needed
    if (_cvFieldMap != null) {
      if (_cvFieldMap!.length != fields.length) {
        _cvFieldMap = null;
      }
    }
    _cvFieldMap ??=
        Map.fromEntries(fields.map((field) => MapEntry(field.name, field)));
    return _cvFieldMap![name]?.cast<T>();
  }

  @override
  int get hashCode => fields.first.hashCode;

  @override
  bool operator ==(other) {
    if (other is CvModelRead) {
      return cvModelsAreEquals(this, other);
    }
    return false;
  }

  @override
  void fromMap(Map map, {List<String>? columns}) {
    debugCheckCvFields();
    // assert(map != null, 'map cannot be null');
    columns ??= fields.map((e) => e.name).toList();
    var model = asModel(map);
    for (var column in columns) {
      try {
        var field = dynamicField(column)!;
        ModelEntry? entry;

        if (field is CvFieldWithParent) {
          var parentModel = model;
          var parentField = field;
          while (true) {
            var child = parentModel[parentField.parent];
            if (child is Map) {
              parentModel = asModel(child);
              var subField = parentField.field;
              if (subField is CvFieldWithParent) {
                parentField = subField;
              } else if (subField is CvFieldContent) {
                var modelEntry = parentModel.getMapEntry(subField.name);
                var modelEntryValue = modelEntry?.value;
                if (modelEntryValue is Map) {
                  entry = ModelEntry(
                      modelEntry!.key.toString(),
                      subField.create(modelEntryValue)
                        ..fromMap(modelEntryValue));
                }

                break;
                //subField.create(modelEntry)..fromMap(modelEntry)
              } else {
                entry = parentModel.getMapEntry(subField.name);
                break;
              }
            } else {
              // Not valid data
              break;
            }
          }
        } else {
          entry = model.getMapEntry(field.name);
        }
        if (entry != null) {
          if (field is CvFieldContentList) {
            var list = field.v = field.createList();
            for (var rawItem in entry.value as List) {
              var item = field.create(rawItem as Map)..fromMap(rawItem);
              list.add(item);
            }
            field.v = list;
          } else if (field is CvFieldContent) {
            var entryValue = entry.value as Map;
            var cvModel = field.create(entryValue);
            field.v = cvModel;
            cvModel.fromMap(entryValue);
          } else if (field is CvListField) {
            if (field.isBasicItemType) {
              field.fromBasicTypeValueList(entry.value);
            } else {
              var list = field.v = field.createList();
              for (var rawItem in entry.value as List) {
                list.add(rawItem);
              }
            }
          } else if (field is CvModelMapField) {
            var map = field.v = field.createMap();
            var entryValue = entry.value as Map;
            entryValue.forEach((key, value) {
              var item = field.create(value as Map)..fromMap(value);
              map[key as String] = item;
            });
          } else if (field is CvFieldEncodedImpl) {
            // Decode
            Object? decodedValue;
            var encodedValue = entry.value;
            if (field.codec != null) {
              decodedValue = field.codec!.decode(encodedValue);
            } else {
              decodedValue = encodedValue;
            }
            field.v = decodedValue;
          } else if (field is CvFieldImpl && field.isBasicType) {
            /// Only replace
            field.fromBasicTypeValue(entry.value, presentIfNull: true);
          } else {
            try {
              field.v = entry.value;
            } catch (_) {
              // Special string handling
              if (field.type == String) {
                field.v = entry.value?.toString();
              } else {
                rethrow;
              }
            }
          }
        }
      } catch (e) {
        if (debugContent) {
          // ignore: avoid_print
          print('ERROR fromMap($map, $columns) at $column');
        }
        if (e is CvBuilderException) {
          rethrow;
        }
      }
    }
  }

  @override
  Map<String, Object?> toMap(
      {List<String>? columns, bool includeMissingValue = false}) {
    debugCheckCvFields();

    void modelToMap(Model model, CvField field) {
      dynamic value = field.v;
      if (value is List<CvModelRead>) {
        value = value
            .map((e) => e.toMap(includeMissingValue: includeMissingValue))
            .toList();
      } else if (value is CvModelRead) {
        value = value.toMap(includeMissingValue: includeMissingValue);
      }
      if (field is CvFieldWithParent) {
        // Check sub model
        if (field.hasValue || includeMissingValue) {
          var subModel = model[field.parent] as Model?;
          if (subModel is! Model) {
            subModel = <String, Object?>{};
            model.setValue(field.parent, subModel);
          }
          // Try existing if any
          modelToMap(subModel, field.field);
        }
      } else if (field is CvModelMapField && field.isNotNull) {
        // The submodel will be a mode too, replace existing if any
        var subModel = model[field.key] as Model?;
        if (subModel is! Model) {
          subModel = newModel();
          model.setValue(field.key, subModel);
        }
        field.valueOrNull?.forEach((key, value) {
          subModel![key] =
              value.toMap(includeMissingValue: includeMissingValue);
        });
      } else if (field is CvFieldEncodedImpl && field.isNotNull) {
        Object? encodedValue;
        if (field.codec != null) {
          encodedValue = field.codec!.encode(value);
        } else {
          encodedValue = value;
        }
        model.setValue(field.name, encodedValue,
            presentIfNull: field.hasValue || includeMissingValue);
      } else {
        model.setValue(field.name, value,
            presentIfNull: field.hasValue || includeMissingValue);
      }
    }

    var model = <String, Object?>{};

    if (columns == null) {
      for (var field in fields) {
        modelToMap(model, field);
      }
    } else {
      for (var column in columns) {
        var field = dynamicField(column);
        if (field != null) {
          modelToMap(model, field);
        }
      }
    }
    return model;
  }

  @override
  void clear() {
    for (var field in fields) {
      field.clear();
    }
  }
}

final _debugCvFieldsCheckDone = <Type, bool>{};

@Deprecated('Debug only')

/// Result field check in debug mode (A field is only tested once).
void debugResetCvModelFieldChecks() => _debugCvFieldsCheckDone.clear();

/// Private extension on CvModel
extension CvModelPrvExt<T> on CvModelCore {
  /// Debug check
  void debugCheckCvFields() {
    if (isDebug) {
      var success = _debugCvFieldsCheckDone[runtimeType];

      if (success == null) {
        // Mark pending
        _debugCvFieldsCheckDone[runtimeType] = false;
        var fieldNames = <String>{};
        for (var field in fields) {
          if (fieldNames.contains(field.name)) {
            _debugCvFieldsCheckDone[runtimeType] = false;
            throw CvBuilderExceptionImpl(
                'Duplicated CvField ${field.name} in $runtimeType${fields.map((f) => f.name)} - $this');
          }
          fieldNames.add(field.name);
        }
        _debugCvFieldsCheckDone[runtimeType] = success = true;
      } else if (!success) {
        // Don't yell again
      }
    }
  }
}

/// Public extension on CvModelWrite
extension CvModelWriteExt on CvModelWrite {
  /// Copy content
  void copyFrom(CvModelRead model, {List<String>? columns}) {
    debugCheckCvFields();
    fromMap(model.toMap(columns: columns));
  }
}

/// Public extension on CvModelWrite
extension CvModelCloneExt<T extends CvModel> on T {
  /// Copy content
  T clone() {
    return cvClone<T>(this);
  }
}

/// Public extension on CvModelCore
extension CvModelReadExt on CvModelRead {
  /// Deep CvField access
  CvField<T>? fieldAtPath<T extends Object?>(List<Object> parts) {
    var path = parts.first;
    if (path is String) {
      var rawField = field<Object>(path);
      if (rawField?.isNotNull ?? false) {
        return rawGetFieldAtPath<T>(rawField!, parts.sublist(1));
      }
    }
    return null;
  }

  /// Get a value at a given path
  /// fields value is returned. `CvModel/List<CvModel>` are converted to map/mapList.
  T? valueAtPath<T extends Object?>(List<Object> parts) {
    var path = parts.first;
    if (path is String) {
      var rawValue = field<Object>(path)?.value;
      if (rawValue != null) {
        return rawGetValueAtPath(rawValue, parts.sublist(1));
      }
    }
    return null;
  }
}
