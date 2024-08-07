import 'package:cv/cv.dart';
import 'package:cv/cv.dart' as cvimpl;

import 'cv_model_mixin.dart';
import 'map_ext.dart';

/// Convenient extension on Model
extension ModelRawListExt on List {
  /// ['key1', 'key2', index3, 'key4]
  T? getKeyPathValue<T extends Object?>(List<Object> paths) {
    Object? rawValue;
    var path = paths.first;
    if (path is int && length > path) {
      rawValue = this[path];
      return rawGetKeyPathValue(rawValue, paths.sublist(1));
    }

    return null;
  }

  /// Handle [0, 'key2', 4, 'key4] first must be an int
  CvField<F>? fieldAtPath<F extends Object?>(List<Object> paths) {
    var path = paths.first;
    if (path is int && length > path) {
      var rawValue = this[path];
      // i.e. not null.
      if (rawValue is Object) {
        return rawGetFieldAtPath<F>(rawValue, paths.sublist(1));
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
