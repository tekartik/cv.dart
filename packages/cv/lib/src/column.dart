/// Raw column implementation.
abstract class RawColumn {
  /// Column name.
  String get name;
}

/// Content value column.
abstract class CvColumn<T> implements RawColumn {
  /// Column creation.
  factory CvColumn(String name) => ColumnImpl(name);

  /// Column type.
  Type get type;
}

/// Column implementation.
class ColumnImpl<T>
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
