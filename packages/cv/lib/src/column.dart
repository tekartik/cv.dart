import 'cv_column.dart';
export 'cv_column.dart'; // compat

/// Raw column implementation.
abstract class RawColumn {
  /// Column name.
  String get name;
}

/// Column implementation.
class ColumnImpl<T extends Object?>
    with CvColumnMixin<T>, ColumnNameMixin
    implements CvColumn<T> {
  /// Column creation.
  ColumnImpl(String name) {
    this.name = name;
  }
}

/// Column implementaiton mixin
mixin ColumnNameMixin implements RawColumn {
  @override
  late String name;

  @override
  bool operator ==(other) {
    if (other is RawColumn) {
      return other.name == name;
    }
    return false;
  }
}

/// Content value column mixin
mixin CvColumnMixin<T> implements CvColumn<T> {
  @override
  Type get type => T;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Column($name)';
}
