import 'package:cv/src/model.dart';

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

/// Create a new model - prefer newModel()
@Deprecated('Use newModel()')
Model NewModel() => newModel(); // ignore: non_constant_identifier_names

/// Create a new model
Model newModel() => <K, V>{};

/// Create a new model list - prefer newModelList()
@Deprecated('Use newModelList()')
ModelList NewModelList() => <Model>[]; // ignore: non_constant_identifier_names

/// Create a new model list
ModelList newModelList() =>
    newModelList(); // ignore: non_constant_identifier_names
