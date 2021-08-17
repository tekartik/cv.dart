import 'package:cv/src/model.dart';

import 'model.dart';

/// Key type
typedef K = String;

/// Value type
typedef V = Object?;

/// Model type
typedef Model = Map<K, V>;

/// Model list type
typedef ModelList = List<Model>;

/// Model entry
typedef ModelEntry = MapEntry<K, V>;

/// Cast the map if needed.
Model asModel(Map map) => map is Model ? map : map.cast<K, V>();

/// Cast the list if needed.
ModelList asModelList(Iterable list) =>
    list is ModelList ? list : ModelListImpl(list);

/// Create a new model
Model NewModel() => <K, V>{}; // ignore: non_constant_identifier_names

/// Create a new model list
ModelList NewModelList() => <Model>[]; // ignore: non_constant_identifier_names
