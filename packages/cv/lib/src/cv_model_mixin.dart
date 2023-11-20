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
    Object rawValue, List<Object> paths) {
  if (paths.isEmpty) {
    if (rawValue is CvField<T>) {
      return rawValue;
    }
    return null;
  }
  if (rawValue is CvModelField) {
    return rawValue.v?.fieldAtPath<T>(paths);
  } else if (rawValue is CvModelListField) {
    return rawValue.v?.fieldAtPath<T>(paths);
  } else if (rawValue is CvModel) {
    return rawValue.fieldAtPath<T>(paths);
  } else if (rawValue is List) {
    return rawValue.fieldAtPath<T>(paths);
  }
  return null;
}

/// Content mixin
mixin CvModelMixin implements CvModel {
  /// Copy content
  @override
  void copyFrom(CvModel model, {List<String>? columns}) {
    _debugCheckCvFields();
    for (var field in fields.matchingColumns(columns)) {
      var recordCvField = model.dynamicField(field.name);
      if (recordCvField != null) {
        // ignore: invalid_use_of_visible_for_testing_member
        field.fromCvField(recordCvField);
      }
    }
  }

  void _debugCheckCvFields() {
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
        /*
        throw UnsupportedError(
            'Duplicated CvFields in $runtimeType${fields.map((f) => f.name)} - $this');

         */
      }
    }
  }

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
  CvField<T>? fieldAtPath<T extends Object?>(List<Object> paths) {
    var path = paths.first;
    if (path is String) {
      var rawField = field<Object>(path);
      if (rawField?.isNotNull ?? false) {
        return rawGetFieldAtPath<T>(rawField!, paths.sublist(1));
      }
    }

    return null;
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
    _debugCheckCvFields();
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
            var list = field.v = field.createList();
            for (var rawItem in entry.value as List) {
              list.add(rawItem);
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
    _debugCheckCvFields();

    void modelToMap(Model model, CvField field) {
      dynamic value = field.v;
      if (value is List<CvModelCore>) {
        value = value.map((e) => (e as CvModelRead).toMap()).toList();
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
