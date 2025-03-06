import 'package:cv/cv.dart';
import 'package:cv/src/list_ext.dart';
import 'package:cv/src/map_ext.dart';

/// Set raw value helper for map and list - internal
/// parts must not be empty
bool anyRawSetValueAtPath<T extends Object?>(
  Object rawValue,
  List<Object> parts,
  Object? value,
) {
  if (rawValue is CvModel) {
    return rawValue.setValueAtPath(parts, value);
  } else if (rawValue is Map) {
    return rawValue.rawSetValueAtPath(parts, value);
  } else if (rawValue is List) {
    return rawValue.rawSetValueAtPath(parts, value);
  }
  return false;
}
