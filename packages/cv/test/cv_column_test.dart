import 'package:cv/src/column.dart';
import 'package:test/test.dart';

void main() {
  group('Column', () {
    test('equals', () async {
      expect(CvColumn<Object?>('name'), CvColumn<String>('name'));
      expect(CvColumn<int>('name'), isNot(CvColumn<int>('name2')));
    });
  });
}
