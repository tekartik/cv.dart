import 'package:cv/src/list_ext.dart';
import 'package:cv/src/map_ext.dart';

/// Global extension on any object.
extension ModelRawObjectExt on Object {
  /// Convert any object to a specific type.
  /// Example: `anyAs<Map>` or `anyAs<List>` or `anyAs<Map?>` to support nullable types.
  T anyAs<T>() {
    if (this is T) {
      return this as T;
    }
    return null as T;
  }

  /// Deep clone a map or a list.
  T anyDeepClone<T>() {
    if (this is Map) {
      return (this as Map).deepClone() as T;
    } else if (this is List) {
      return (this as List).deepClone() as T;
    }
    return this as T;
  }
}
