import 'package:cv/cv.dart';
import 'package:cv/src/list_ext.dart';
import 'package:cv/src/map_ext.dart';

import 'cv_model_mixin.dart';

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

/// Return an actual existing field
/// the incoming parts must not be empty
/// if returned parts is null, it means the field value itself is involved
(CvField<T>?, List<Object>? parts) anyRawGetFieldAndPartsAtPath<
  T extends Object?
>(CvFieldAndParts parent, Object rawValue, List<Object> parts) {
  if (rawValue is CvModel) {
    return rawValue.fieldAndPartsAtPath<T>(parts);
  } else if (rawValue is Map) {
    return rawValue.rawGetFieldAndPartsAtPath<T>(parent, parts);
  } else if (rawValue is List) {
    return rawValue.rawGetFieldAndPartsAtPath<T>(parent, parts);
  }
  return (null, null);
}
