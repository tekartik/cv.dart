import 'package:cv/cv.dart';
import 'package:cv/src/field.dart';

/// Class that has parent map
abstract class CvFieldWithParent<T extends Object?> implements CvField<T> {
  /// The actual field.
  CvField<T> get field;

  /// Parent name.
  String get parent;
}

/// Field with parent implementation.
class CvFieldWithParentImpl<T extends Object?>
    with CvFieldHelperMixin<T>
    implements CvFieldWithParent<T> {
  @override
  final CvField<T> field;
  @override
  final String parent;

  /// Field with parent.
  CvFieldWithParentImpl(this.field, this.parent);

  @override
  T? get valueOrNull => field.value;

  @override
  CvField<RT> cast<RT>() => field.cast<RT>().withParent(parent);

  @override
  void clear() {
    field.clear();
  }

  @override
  void fromCvField(CvField cvField) {
    field.fromCvField(cvField);
  }

  @override
  bool get hasValue => field.hasValue;

  @override
  bool get isNull => field.isNull;

  @override
  String get key => '$parent.${field.name}';

  @override
  String get name => key;

  @override
  void setNull() {
    field.setNull();
  }

  @override
  void setValue(T? value, {bool presentIfNull = false}) {
    field.setValue(value, presentIfNull: presentIfNull);
  }

  @override
  Type get type => field.type;

  @override
  CvField<T> withParent(String parent) {
    // TODO: implement withParent
    throw UnimplementedError();
  }

  @override
  set valueOrNull(T? value) {
    field.value = value;
  }

  @override
  String toString() {
    return '$parent.$field';
  }

  @override
  int get hashCode => key.hashCode + (v?.hashCode ?? 0);

  @override
  bool operator ==(other) {
    if (other is CvField) {
      if (other.key != key) {
        return false;
      }
      if (other.hasValue != hasValue) {
        return false;
      }
      if (!cvValuesAreEqual(other.v, v)) {
        return false;
      }
      return true;
    }
    return false;
  }
}
