import 'package:cv/cv.dart';

/// Convenient extension on Model
extension ModelListExt on ModelList {
  /// Generate a list of cv model.
  List<T> cv<T extends CvModel>({T Function(Map contextData)? builder}) {
    return map((map) => map.cv<T>(builder: builder)).toList();
  }
}
