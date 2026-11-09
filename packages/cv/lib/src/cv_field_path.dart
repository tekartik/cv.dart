// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:cv/cv.dart';
import 'package:meta/meta.dart';

/// Backtick char code.
const _backtickChr = '`';

extension on String {
  bool get _isBacktickEnclosed {
    final length = this.length;
    if (length < 2) {
      return false;
    }
    return this[0] == _backtickChr && this[length - 1] == _backtickChr;
  }

  List<Object> _parseFieldParts() {
    var parts = <Object>[];
    var start = 0;
    while (true) {
      /// Backtick enclosed part (it can hold dots): up to the closing
      /// backtick followed by a dot or the end.
      if (start < length && this[start] == _backtickChr) {
        var close = start + 1;
        while ((close = indexOf(_backtickChr, close)) != -1) {
          var end = close + 1;
          if (end == length || this[end] == '.') {
            parts.add(substring(start + 1, close));
            if (end == length) {
              return parts;
            }
            start = end + 1;
            break;
          }
          close = end;
        }
        if (close != -1) {
          continue;
        }
      }
      var dot = indexOf('.', start);
      var part = dot == -1 ? substring(start) : substring(start, dot);
      parts.add(_parseFieldPart(part));
      if (dot == -1) {
        return parts;
      }
      start = dot + 1;
    }
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
/// Class representing [CvFieldPath].
class CvFieldPath implements CvTreePath {
  /// Creates a new [CvFieldPath].
  CvFieldPath(this.parts)
    : assert(parts.isNotEmpty),
      assert(
        parts.where((component) => !(component._isPathPart)).isEmpty,
        'Expected all CvFieldPath parts to be integer or non-empty strings.',
      );

  /// Creates a new [CvFieldPath] from a string path.
  ///
  /// The [CvFieldPath] will created by splitting the given path by the
  /// '.' character
  CvFieldPath.fromString(String path) : this(path._parseFieldParts());

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

  /// Text representation of the path.
  String get text => parts.map((part) => part._partText).join('.');
  @override
  bool operator ==(Object other) =>
      // Same as CvTreePath, so that equality is symmetric.
      other is CvTreePath &&
      const IterableEquality<Object>().equals(other.parts, parts);

  @override
  int get hashCode => Object.hashAll(parts);

  @override
  String toString() => 'CvFieldPath($parts)';

  @override
  int get length => parts.length;
}
