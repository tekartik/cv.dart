import 'package:cv/cv.dart';
import 'package:cv/src/cv_model.dart';
import 'package:cv/src/cv_model_mixin.dart';

/// `Map<String, CvModel>` convenient read extensions.
extension CvModelMapReadExt<T extends CvModelRead> on Map<String, T> {
  /// Deep CvField access
  CvField<F>? fieldAtPath<F extends Object?>(List<Object> paths) {
    var path = paths.first;
    if (path is String) {
      var child = this[path];
      if (child != null) {
        return rawGetFieldAtPath<F>(child, paths.sublist(1));
      }
    }
    return null;
  }
}
