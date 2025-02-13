import 'dart:collection';

import 'package:cv/cv.dart';
import 'package:cv/src/cv_model_mixin.dart';

import 'cv_model.dart';

/// Empty map.
const cvEmptyMapList = <Model>[];

/// New empty cv model list.
List<T> cvNewModelList<T extends CvModel>({bool lazy = true}) =>
    cvEmptyMapList.cv<T>(lazy: lazy);

/// New empty cv model list.
List<T> cvTypeNewModelList<T extends CvModel>(Type type, {bool lazy = true}) =>
    cvEmptyMapList.cvType(type, lazy: lazy);

/// `List<CvModel>` convenient extensions.
extension CvModelReadListExt<T extends CvModelRead> on List<T> {
  /// Convert to model list
  List<Model> toMapList({
    List<String>? columns,
    bool includeMissingValue = false,
  }) {
    return map(
      (e) =>
          e.toMap(columns: columns, includeMissingValue: includeMissingValue),
    ).toList();
  }

  /// Deep CvField access
  CvField<F>? fieldAtPath<F extends Object?>(List<Object> paths) {
    var path = paths.first;
    if (path is int && length > path) {
      var rawField = this[path];

      return rawGetFieldAtPath<F>(rawField, paths.sublist(1));
    }
    return null;
  }
}

/// Lazy model list. item are converted when requested.
///
/// The list is modifiable too.
class LazyModelList<T extends CvModel> extends ListBase<T> {
  /// The base model list.
  final List<Model> mapList;

  /// The converted list.
  late List<T?> lazyList;

  /// Optional builder functions.
  final CvBuilderFunction<T>? builder;

  /// Constructor.
  LazyModelList({required this.mapList, this.builder}) {
    lazyList = List<T?>.filled(mapList.length, null, growable: true);
  }

  @override
  T operator [](int index) {
    return lazyList[index] ??= mapList[index].cv<T>(builder: builder);
  }

  @override
  void operator []=(int index, T value) {
    lazyList[index] = value;
  }

  @override
  int get length => lazyList.length;

  @override
  set length(int newLength) {
    lazyList.length = newLength;
  }
}
