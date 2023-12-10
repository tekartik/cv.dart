import 'package:cv/cv.dart';

/// Tree path
///
/// Being all string or int index
class CvTreePath {
  /// Tree path parts
  final Iterable<Object> parts;

  /// Tree path.
  CvTreePath(this.parts);

  @override
  String toString() => parts.join('.');
}

class _TreePathState {
  final Object part;
  final _TreePathState? parent;

  _TreePathState(this.part, this.parent);

  Iterable<Object> get parts sync* {
    if (parent != null) {
      yield* parent!.parts;
    }
    if (part != '') {
      yield part;
    }
  }
}

_TreePathState? _treePathState;

/// Public extension on CvModelRead
extension CvTreePathModelReadExt<T extends CvModel> on T {
  /// Path sub computation.
  T get cvPath {
    _treePathState ??= _TreePathState('', null);
    return this;
  }
}

/// Public extension on CvModelRead
extension CvTreePathFieldExt on CvField {
  /// Path final computation.
  CvTreePath get treePath {
    var state = _treePathState;
    assert(
        state != null, 'path<F> must be called inside a  model path<F> block');

    state = _TreePathState(key, _treePathState);
    _treePathState = null;
    return CvTreePath(state.parts);
  }

  /// Field path paths
  Iterable<Object> get pathParts => treePath.parts;
}

/// Public extension on CvModelRead
extension CvTreePathListFieldExt on CvListField {
  /// Path final computation at index.
  CvTreePath treePathAt(int index) {
    var state = _treePathState;
    assert(
        state != null, 'path<F> must be called inside a  model path<F> block');

    state = _TreePathState(index, _TreePathState(key, _treePathState));
    _treePathState = null;
    return CvTreePath(state.parts);
  }
}

/// Public extension on CvListField
extension CvTreePathModelListFieldExt<T extends CvModel>
    on CvModelListField<T> {
  /// Sub list index.
  T pathSubAt(int index) {
    assert(_treePathState != null,
        'path<F> must be called inside a  model path<F> block');

    _treePathState = _TreePathState(index, _TreePathState(key, _treePathState));
    return create({});
  }
}

/// Public extension on CvModelMapField
extension CvTreePathModelMapField<T extends CvModel> on CvModelMapField<T> {
  /// Sub map index.
  T pathSubAt(String key) {
    assert(_treePathState != null,
        'path<F> must be called inside a  model path<F> block');

    _treePathState =
        _TreePathState(key, _TreePathState(this.key, _treePathState));
    return create({});
  }
}

/// Public extension on CvModelField
extension CvTreePathModelFieldExt<T extends CvModel> on CvModelField<T> {
  /// Path sub computation.
  T get pathSub {
    assert(_treePathState != null,
        'path<F> must be called inside a  model path<F> block');

    _treePathState = _TreePathState(key, _treePathState);
    return create({});
  }
}
