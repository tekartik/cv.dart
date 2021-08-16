abstract class RawColumn {
  String get name;
}

abstract class CvColumn<T> implements RawColumn {
  factory CvColumn(String name) => ColumnImpl(name);

  Type get type;

  bool get isTypeInt;

  bool get isTypeString;
}

class ColumnImpl<T>
    with CvColumnMixin<T>, ColumnNameMixin
    implements CvColumn<T> {
  ColumnImpl(String name) {
    this.name = name;
  }
}

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

mixin CvColumnMixin<T> implements CvColumn<T> {
  @override
  Type get type => T;

  @override
  int get hashCode => name.hashCode;

  @override
  bool get isTypeInt => T == int;

  @override
  bool get isTypeString => T == String;

  @override
  String toString() => 'Column($name)';
}
