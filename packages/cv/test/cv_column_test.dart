import 'package:cv/cv.dart';
import 'package:test/test.dart';

void main() {
  group('Column', () {
    test('equals', () async {
      expect(CvColumn<Object?>('name'), CvColumn<String>('name'));
      expect(CvColumn<int>('name'), isNot(CvColumn<int>('name2')));
    });
    test('type', () {
      CvColumn<Object?> column = CvColumn<String>('test');
      expect(column.type.toString(), 'String');
      column = CvColumn<int>('test');
      expect(column.type.toString(), 'int');
    });
    test('strict-inference ok', () {
      var column = CvColumn('test');
      expect(column.type.toString(), 'Object?');
    });
  });
}
