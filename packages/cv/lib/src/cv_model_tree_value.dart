import 'package:cv/cv.dart';

/// A value wrapper for any element in the tree.
abstract class CvModelTreeValue<T extends CvModel, V extends Object?> {
  /// The model
  T get model;

  /// Value predefined type if any
  Type? get type;

  /// Read value if any
  V? get value;

  /// Could be found but null!
  bool get found;

  /// Set a value
  void setValue(V? value, {bool? presentIfNull});
}

class _CvModelTreeValue<T extends CvModel, V extends Object?>
    implements CvModelTreeValue<T, V> {
  @override
  final T model;
  final CvTreePath treePath;
  Type? _type;
  @override
  Type? get type => _type;
  bool present = false;
  V? _value;
  @override
  V? get value => _value;

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
  void setValue(V? value, {bool? presentIfNull}) {
    if (found) {
      var lastNode = _nodes.last;
      var field = lastNode.field;
      if (field != null) {
        field.setValue(value, presentIfNull: presentIfNull ?? false);
        present = field.hasValue;
        _value = value;
      } else {
        var lastPart = parentPart;

        if (lastPart is int) {
          var parentListNode = _nodes[_nodes.length - 2];
          var parentList = parentListNode.value;
          if (parentList is List) {
            parentList[lastPart] = value;
            present = true;
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
        present = childTmv.present;
        _value = childTmv.value as V?;
        _type ??= childTmv.type;
        return;
      } else if (parentValue is Map) {
        if (parentValue.containsKey(first)) {
          var child = parentValue[first];

          _nodes.add(
            _TreeNodeInfo(treePath: CvTreePath([first]), value: child),
          );
          if (treePath.parts.length == 1) {
            _value = child as V?;
            present = true;
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
            present = true;
            if (parentField is CvListField) {
              _type ??= parentField.itemType;
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
        if (treePath.parts.length == 1) {
          _type ??= field.type;
          _value = field.v as V?;
          present = field.hasValue;
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
