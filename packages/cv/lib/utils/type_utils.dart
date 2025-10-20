import 'package:cv/cv.dart';

/// Extension methods to check subtype and supertype relationships
extension CvColumnTypeExtension<T extends Object?> on CvColumn<T> {
  /// Returns true if T is a subtype of SUPERTYPE
  bool isSubtypeOf<SUPERTYPE>() => <T>[] is List<SUPERTYPE>;

  /// Returns true if T is a supertype of SUBTYPE
  bool isSupertypeOf<SUBTYPE>() => <SUBTYPE>[] is List<T>;
}
