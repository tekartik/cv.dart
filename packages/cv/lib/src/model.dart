import 'dart:collection';

import 'package:cv/cv.dart';

/// Base model.
abstract class ModelBase with MapMixin<String, Object?> {
  late final Model _map;

  /// Base model
  ModelBase(Map? map) {
    _map = map == null ? <String, Object?>{} : asModel(map);
  }

  @override
  Object? operator [](Object? key) => _map[key];

  @override
  void operator []=(String key, Object? value) => _map[key] = value;

  @override
  void clear() {
    _map.clear();
  }

  @override
  Iterable<String> get keys => _map.keys;

  @override
  Object? remove(Object? key) => _map.remove(key);
}

/// List class to use as a `[List<dynamic>]`.
class ModelListImpl extends ModelListBase {
  /// Create a model. If list is null, the model
  /// is an empty list

  ModelListImpl(Iterable<dynamic> super.iterable);
}

/// Base model list.
abstract class ModelListBase with ListMixin<Model> {
  late final ModelList _mapList;

  /// Base model list.
  ModelListBase(Iterable<Object?>? iterable) {
    if (iterable is ModelList) {
      _mapList = iterable;
    } else {
      _mapList = <Model>[
        if (iterable != null) ...iterable.map((e) => asModel(e as Map))
      ];
    }
  }
  @override
  int get length => _mapList.length;

  @override
  Model operator [](int index) => _mapList[index];

  @override
  void operator []=(int index, Model value) {
    _mapList[index] = value;
  }

  @override
  set length(int newLength) => _mapList.length = newLength;

  @override
  void add(Model element) => _mapList.add(element);

  @override
  void addAll(Iterable<Model> iterable) => _mapList.addAll(iterable);
}
