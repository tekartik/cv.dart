import 'package:cv/cv.dart';
import 'package:cv/src/cv_typed.dart';
import 'package:cv/src/cv_value.dart';

/// A value wrapper for any element in the tree.
abstract class CvModelTreeValue<T extends CvModel, V extends Object?>
    implements CvValueWriter<V>, RawTyped {
  /// The model
  T get model;

  /// The path
  CvTreePath get treePath;

  /// For list only, null otherwise
  Type? get listItemType;

  /// Could be found but null or unset
  bool get found;

  /// Set a value
  @override
  void setValue(V? value, {bool presentIfNull = false});
}

/// Private extension
extension CvModelTreeValueExt<T extends CvModel, V extends Object?>
    on CvModelTreeValue<T, V> {
  _CvModelTreeValue<T, V> get _impl => this as _CvModelTreeValue<T, V>;

  /// Only valid if [found] is true and [value] is a list
  C listCreateItem<C>() {
    if (found) {
      var lastNode = _impl._nodes.last;
      var field = lastNode.field;
      if (field != null) {
        if (field is CvModelListField) {
          var value = field.create({}) as C;
          return value;
        }
      }
    }
    throw UnsupportedError('Not found $this');
  }
}

class _CvModelTreeValue<T extends CvModel, V extends Object?>
    implements CvModelTreeValue<T, V> {
  @override
  final T model;
  @override
  final CvTreePath treePath;
  Type? _type;
  @override
  Type get type => _type ?? Object;
  bool _present = false;
  V? _value;
  @override
  V? get value => _value;
  Type? _listItemType;
  @override
  Type? get listItemType => _listItemType;

  /// Parent value
  CvModelTreeValue<T, Object?>? parent;

  /// Parent key/index if any
  Object get parentPart => parts.last;
  Object get topPart => parts.first;
  List<Object> get parts => treePath.parts.toList();

  @override
  bool get found => _nodes.length == parts.length;
  final _nodes = <_TreeNodeInfo>[];
  @override
  void setValue(V? value, {bool presentIfNull = false}) {
    if (found) {
      var lastNode = _nodes.last;
      var field = lastNode.field;
      if (field != null) {
        field.setValue(value, presentIfNull: presentIfNull);
        _present = field.hasValue;
        _value = value;
      } else {
        var lastPart = parentPart;

        if (lastPart is int) {
          var parentListNode = _nodes[_nodes.length - 2];
          var parentList = parentListNode.value;
          if (parentList is List) {
            parentList[lastPart] = value;
            _present = true;
            _value = value;
            return;
          }
        } else if (lastPart is String) {
          var parentMapNode = _nodes[_nodes.length - 2];
          var parentMap = parentMapNode.value;
          if (parentMap is Map) {
            parentMap.setValue<V?>(
              lastPart,
              value,
              presentIfNull: presentIfNull,
            );

            _present = value != null || presentIfNull;
            _value = value;
            return;
          }
        }
      }
    }
  }

  void _next(final List<Object> parts) {
    var nodeCount = _nodes.length;
    var currentTopParts = this.parts.sublist(0, nodeCount);
    var parentNode = _nodes.last;
    var first = parts.first;
    var parentValue = parentNode.value;
    var parentField = parentNode.field;
    void doNext() {
      _next(parts.sublist(1));
    }

    if (first is String) {
      if (parentValue is CvModel) {
        var childTmv = parentValue.prvCvTreeValueAtPath(
          CvTreePath(parts),
          parent: this,
        );
        _nodes.addAll(
          (childTmv._nodes.map((node) {
            return _TreeNodeInfo(
              treePath: CvTreePath([
                ...currentTopParts,
                ...node.treePath.parts,
              ]),
              field: node.field,
              value: value,
            );
          }).toList()),
        );
        // print('nodes: ${_nodes}');
        _present = childTmv._present;
        _value = childTmv.value as V?;
        _type ??= childTmv.type;
        return;
      } else if (parentValue is Map) {
        if (parentValue.containsKey(first)) {
          var child = parentValue[first];

          _nodes.add(
            _TreeNodeInfo(treePath: CvTreePath([first]), value: child),
          );
          if (parts.length == 1) {
            _value = child as V?;
            _present = true;
            return;
          } else {
            doNext();
            return;
          }
        }
      }
    } else if (first is int) {
      if (parentValue is List) {
        var child = parentValue[first];

        if (child != null) {
          _nodes.add(
            _TreeNodeInfo(treePath: CvTreePath([first]), value: child),
          );
          if (parts.length == 1) {
            _value = child as V?;
            _present = true;
            if (parentField is CvListField) {
              _type ??= parentField.itemType;
              _listItemType = parentField.itemType;
            }
            return;
          } else {
            var nextParts = parts.skip(1).toList();
            _next(nextParts);
            return;
          }
        }
      }
    }
  }

  void _init() {
    var first = topPart;
    if (first is String) {
      var field = model.field(first);
      if (field != null) {
        _nodes.add(_TreeNodeInfo(treePath: CvTreePath([first]), field: field));
        if (parts.length == 1) {
          _type ??= field.type;
          _value = field.v as V?;
          _present = field.hasValue;
          if (field is CvListField) {
            _listItemType = field.itemType;
          }
          return;
        } else {
          var nextParts = parts.skip(1).toList();
          _next(nextParts);
          return;
        }
      }
    }
  }

  _CvModelTreeValue(this.model, this.treePath, {this.parent, Type? type})
    : _type = type {
    _init();
  }

  @override
  String toString() => 'CvModelTreeValue($treePath, $type, $model';

  @override
  bool get hasValue => _present;
}

class _TreeNodeInfo {
  final CvField? field;
  late final Object? value;
  final CvTreePath treePath;

  _TreeNodeInfo({required this.treePath, this.field, Object? value}) {
    this.value = value ?? field?.v;
  }

  @override
  String toString() => 'TreeNodeInfo($treePath, $field, $value)';
}

/// Private helper extension for [CvModel].
extension CvTreePathModelReadPrvExt<T extends CvModel> on T {
  /// Get a value at a path.
  // ignore: library_private_types_in_public_api
  _CvModelTreeValue<T, V> prvCvTreeValueAtPath<V extends Object?>(
    CvTreePath path, {
    CvModelTreeValue<T, Object?>? parent,
    Type? type,
  }) {
    return _CvModelTreeValue<T, V>(this, path, parent: parent, type: type);
  }
}
