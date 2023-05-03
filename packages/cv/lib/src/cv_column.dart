import 'column.dart';

/// Content value column.
abstract class CvColumn<T extends Object?> implements RawColumn {
  /// Column creation.
  factory CvColumn(String name) => ColumnImpl(name);

  /// Column type.
  Type get type;
}
