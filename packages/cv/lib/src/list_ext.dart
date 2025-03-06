import 'package:cv/cv.dart';
import 'package:cv/cv.dart' as cvimpl;

import 'content_helper.dart';
import 'cv_model_mixin.dart';
import 'map_ext.dart';

/// Convenient extension on Model
extension ModelRawListExt on List {
  /// ['key1', 'key2', index3, 'key4]
  T? getKeyPathValue<T extends Object?>(List<Object> parts) {
    Object? rawValue;
    var path = parts.first;
    if (path is int && path >= 0 && path < length) {
      rawValue = this[path] as Object?;
      if (rawValue != null) {
        return anyRawGetKeyPathValue<T>(rawValue, parts.sublist(1));
      }
    }

    return null;
  }

  /// Handle [0, 'key2', 4, 'key4] first must be an int
  CvField<F>? rawFieldAtPath<F extends Object?>(List<Object> parts) {
    var path = parts.first;
    if (path is int && length > path) {
      var rawValue = this[path];
      // i.e. not null.
      if (rawValue is Object) {
        return rawGetFieldAtPath<F>(rawValue, parts.sublist(1));
      }
    }
    return null;
  }

  /// cast to a model list.
  ModelList asModelList() => cvimpl.asModelList(this);

  /// Deep clone a list.
  List<T> deepClone<T extends Object?>() {
    return map<T>((e) => (e as Object?)?.anyDeepClone<T>() as T).toList();
  }
}

/// Convenient private extension on Model
extension ModelRawListPrvExt on List {
  /// parts cannot be empty
  bool rawSetValueAtPath(List<Object> parts, Object? value) {
    var first = parts.first;
    if (first is int) {
      var index = first;
      if (index >= 0 && index < length) {
        if (parts.length == 1) {
          this[index] = value;
          return true;
        } else {
          var entry = this[index];
          if (entry is Object) {
            return anyRawSetValueAtPath(entry, parts.sublist(1), value);
          }
        }
      }
    }
    return false;
  }

  /// Return an actual existing field
  /// the incoming parts must not be empty
  /// if returned parts is null, it means the field value itself is involved
  (CvField<T>?, List<Object>? parts) rawGetFieldAndPartsAtPath<
    T extends Object?
  >(CvFieldAndParts parent, List<Object> parts) {
    var first = parts.first;
    if (first is int) {
      var index = first;
      if (index >= 0 && index < length) {
        var rawValue = this[index];
        if (rawValue is Object) {
          if (parts.length == 1) {
            return parent.sub(first).cast<T>();
          } else {
            return anyRawGetFieldAndPartsAtPath<T>(
              parent,
              rawValue,
              parts.sublist(1),
            );
          }
        }
      }
    }
    return (null, null);
  }
}
