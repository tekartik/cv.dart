import 'package:cv/cv.dart';
import 'package:cv/utils/type_utils.dart';
import 'package:test/test.dart';

void main() {
  group('type_utils', () {
    test('subtype/supertype', () {
      var fieldInt = CvField<int>('intField');

      expect(fieldInt.isSubtypeOf<num>(), isTrue);
      expect(fieldInt.isSupertypeOf<num>(), isFalse);

      var fieldNum = CvField<num>('numField');

      expect(fieldNum.isSubtypeOf<int>(), isFalse);
      expect(fieldNum.isSupertypeOf<int>(), isTrue);

      var fieldString = CvColumn<String>('stringField');

      expect(fieldString.isSubtypeOf<Object>(), isTrue);

      expect(fieldString.isSupertypeOf<Object>(), isFalse);
    });
  });
}
