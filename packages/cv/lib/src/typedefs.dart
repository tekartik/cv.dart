/// Model type
typedef Model = Map<String, Object?>;

/// Model list type
typedef ModelList = List<Map<String, Object?>>;

/// Model entry
typedef ModelEntry = MapEntry<String, Object?>;

/// Cast the map if needed.
Model asModel(Map map) => map is Model ? map : map.cast<String, Object?>();

/// Cast the list if needed.
ModelList asModelList(Iterable list) =>
    list is ModelList ? list : list.cast<Model>().toList();
