// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:cv/cv.dart';
import 'package:meta/meta.dart';

/// Backtick char code.
final _backtickChr = '`';

extension on String {
  bool get _isBacktickEnclosed {
    final length = this.length;
    if (length < 2) {
      return false;
    }
    return this[0] == _backtickChr && this[length - 1] == _backtickChr;
  }

  List<Object> _parseFieldParts() {
    /// Look for backtick enclosed path
    var parts = split('.').map((part) => _parseFieldPart(part)).toList();
    return parts;
  }

  Object _parseFieldPart(String text) {
    if (text._isBacktickEnclosed) {
      return text._unescape();
    }
    var intValue = int.tryParse(text);
    if (intValue != null) {
      return intValue;
    }
    return text;
  }

  String _escape() => '$_backtickChr$this$_backtickChr';
  String _unescape() => substring(1, length - 1);
}

extension on Object {
  bool get _isPathPart {
    var self = this;
    if (self is String) {
      return self.isNotEmpty;
    } else if (self is int) {
      return true;
    }
    return false;
  }

  String get _partText {
    var self = this;
    if (self is String) {
      if (int.tryParse(self) != null) {
        return self._escape();
      }
      if (self.contains('.')) {
        return self._escape();
      }
      return self;
    } else if (self is int) {
      return self.toString();
    }
    throw UnsupportedError('Invalid part $self');
  }
}

/// A [CvFieldPath] refers to a field in a document (either a map child, or a list item)
@immutable
//@Deprecated('Use CvTreePath')
class CvFieldPath implements CvTreePath {
  /// Parent
  CvFieldPath get parent {
    if (!hasParent) {
      throw StateError('No parent for root path');
    }
    return CvFieldPath(parts.sublist(0, parts.length - 1));
  }

  /// True if the path has a parent.
  bool get hasParent => parts.length > 1;

  /// First part of the path.
  Object get firstPart => parts.first;

  /// The [List] of components which make up this [CvFieldPath].
  /// never empty
  @override
  final List<Object> parts;

  /// Creates a new [FieldPath].
  CvFieldPath(this.parts)
    : assert(parts.isNotEmpty),
      assert(
        parts.where((component) => !(component._isPathPart)).isEmpty,
        'Expected all CvFieldPath parts to be integer or non-empty strings.',
      );

  /// Creates a new [CvFieldPath] from a string path.
  ///
  /// The [FieldPath] will created by splitting the given path by the
  /// '.' character
  CvFieldPath.fromString(String path) : this(path._parseFieldParts());

  /// Text representation of the path.
  String get text => parts.map((part) => part._partText).join('.');
  @override
  bool operator ==(Object other) =>
      other is CvFieldPath &&
      const ListEquality<Object>().equals(other.parts, parts);

  @override
  int get hashCode => Object.hashAll(parts);

  @override
  String toString() => 'CvFieldPath($parts)';

  @override
  int get length => parts.length;
}
