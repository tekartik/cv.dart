import 'column.dart';
import 'cv_typed.dart';

/// Content value column.
abstract class CvColumn<T extends Object?> implements RawColumn, RawTyped {
  /// Column creation.
  factory CvColumn(String name) => ColumnImpl(name);

  /// Column type.
  @override
  Type get type;
}
