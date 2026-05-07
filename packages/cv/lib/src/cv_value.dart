/// Value reader interface
abstract class CvValueReader<T> implements CvValueReaderCore {
  /// Get a value
  T? get value;
}

/// Read core value
abstract class CvValueReaderCore {
  /// True if a value is set (even if the value is null)
  bool get hasValue;

  /// Raw value (untyped)
  Object? get rawValue;
}

/// Value writer interface
abstract class CvValueWriter<T> implements CvValueReader<T>, CvValueWriterCore {
  /// Set a value
  void setValue(T? value, {bool presentIfNull = false});

  /// Clear value and flag
  void clear();
}

/// Value writer interface
abstract class CvValueWriterCore {
  /// Set a value
  void setRawValue(Object? value, {bool presentIfNull = false});
}
