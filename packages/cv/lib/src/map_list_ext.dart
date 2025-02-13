import 'package:cv/cv.dart';
import 'package:cv/src/cv_model_list.dart';

/// Convenient extension on Model
extension ModelListExt on ModelList {
  /// Generate a list of cv model.
  List<T> cv<T extends CvModel>({
    T Function(Map contextData)? builder,
    bool lazy = true,
  }) {
    if (lazy) {
      return LazyModelList(mapList: this, builder: builder);
    }
    return map((map) => map.cv<T>(builder: builder)).toList();
  }

  /// Generate a list of cv model.
  List<T> cvType<T extends CvModel>(
    Type type, {
    T Function(Map contextData)? builder,
    bool lazy = true,
  }) {
    if (lazy) {
      return LazyModelList<T>(
        mapList: this,
        builder: cvTypeGetBuilder<T>(type, builder: builder),
      );
    }
    return map((map) => map.cvType<T>(type, builder: builder)).toList();
  }
}
