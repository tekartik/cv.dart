import 'package:cv/cv.dart';
import 'package:cv/cv.dart' as cvimpl;

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
        return rawGetKeyPathValue(rawValue, parts.sublist(1));
      }
    }

    return null;
  }

  /// Handle [0, 'key2', 4, 'key4] first must be an int
  CvField<F>? fieldAtPath<F extends Object?>(List<Object> parts) {
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
