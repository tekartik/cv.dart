import 'package:cv/cv.dart';
import 'package:cv/src/cv_field_with_parent.dart';
import 'package:cv/src/cv_model.dart';

import 'builder.dart';
import 'env_utils.dart';
import 'field.dart';
import 'utils.dart';

/// For dev only
var debugContent = false; // devWarning(true);

/// Content mixin
mixin CvModelMixin implements CvModel {
  /// Copy content
  @override
  void copyFrom(CvModel model) {
    _debugCheckCvFields();
    for (var field in fields) {
      var recordCvField = model.field(field.name);
      if (recordCvField?.hasValue == true) {
        // ignore: invalid_use_of_visible_for_testing_member
        field.fromCvField(recordCvField!);
      }
    }
  }

  void _debugCheckCvFields() {
    if (isDebug) {
      var success = _debugCvFieldsCheckDone[runtimeType];

      if (success == null) {
        // Mark pending
        _debugCvFieldsCheckDone[runtimeType] = false;
        var _fieldNames = <String>{};
        for (var field in fields) {
          if (_fieldNames.contains(field.name)) {
            _debugCvFieldsCheckDone[runtimeType] = false;
            throw CvBuilderExceptionImpl(
                'Duplicated CvField ${field.name} in $runtimeType${fields.map((f) => f.name)} - $this');
          }
          _fieldNames.add(field.name);
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
  CvField<T>? field<T>(String name) {
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
      return cvModelAreEquals(this, other);
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
        var field = this.field(column)!;
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
            var entryValue = entry.value;
            var cvModel = field.create(entryValue as Map);
            field.v = cvModel;
            cvModel.fromMap(entryValue);
          } else if (field is CvListField) {
            var list = field.v = field.createList();
            for (var rawItem in entry.value as List) {
              list.add(rawItem);
            }
            field.v = list;
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

    void _toMap(Model model, CvField field) {
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
          _toMap(subModel, field.field);
        }
      } else {
        model.setValue(field.name, value,
            presentIfNull: field.hasValue || includeMissingValue);
      }
    }

    var model = <String, Object?>{};

    if (columns == null) {
      for (var field in fields) {
        _toMap(model, field);
      }
    } else {
      for (var column in columns) {
        var field = this.field(column);
        if (field != null) {
          _toMap(model, field);
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
