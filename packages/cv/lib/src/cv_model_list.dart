import 'package:cv/cv.dart';

/// List<CvModel> convenient extensions.
extension CvModelListExt<T extends CvModel> on List<T> {
  /// Convert to model list
  List<Map<String, Object?>> toMapList(
      {List<String>? columns, bool includeMissingValue = false}) {
    return map((e) =>
            e.toMap(columns: columns, includeMissingValue: includeMissingValue))
        .toList();
  }
}
