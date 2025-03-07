/// Value reader interface
abstract class CvValueReader<T> {
  /// Get a value
  T? get value;

  /// True if a value is set (even if the value is null)
  bool get hasValue;
}

/// Value writer interface
abstract class CvValueWriter<T> implements CvValueReader<T> {
  /// Set a value
  void setValue(T? value, {bool presentIfNull = false});
}
