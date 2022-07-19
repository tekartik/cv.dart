import 'dart:collection';

import 'package:cv/cv.dart';

/// List<CvModel> convenient extensions.
extension CvModelListExt<T extends CvModel> on List<T> {
  /// Convert to model list
  List<Model> toMapList(
      {List<String>? columns, bool includeMissingValue = false}) {
    return map((e) =>
            e.toMap(columns: columns, includeMissingValue: includeMissingValue))
        .toList();
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
