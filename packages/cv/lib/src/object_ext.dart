/// Global extension on any object.
extension ModelRawObjectExt on Object {
  /// Convert any object to a specific type.
  /// Example: anyAs<Map> or anyAs<List> or anyAs<Map?> to support nullable types.
  T anyAs<T>() {
    if (this is T) {
      return this as T;
    }
    return null as T;
  }
}
