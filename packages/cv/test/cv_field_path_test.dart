import 'package:cv/src/cv_field_path.dart';
import 'package:test/test.dart';

Future<void> main() async {
  group('CvFieldPath', () {
    test('CvFieldPath', () {
      expect(CvFieldPath.fromString('1').parts, [1]);
      expect(CvFieldPath.fromString('`1`').parts, ['1']);
      expect(CvFieldPath.fromString('a.b').parts, ['a', 'b']);
      expect(CvFieldPath.fromString('a.1').parts, ['a', 1]);
      expect(CvFieldPath.fromString('a.`1`').parts, ['a', '1']);
      expect(
        CvFieldPath.fromString('a.b.`1`.2.`3`'),
        CvFieldPath(const ['a', 'b', '1', 2, '3']),
      );
      expect(CvFieldPath(const ['a.b', 'c']).parts, ['a.b', 'c']);
      expect(CvFieldPath(const ['a.b', 'c']).text, '`a.b`.c');
      expect(CvFieldPath(const ['a.b', 1, '2']).text, '`a.b`.1.`2`');
      expect(CvFieldPath(const ['a.b', 1, '2']).text, '`a.b`.1.`2`');
    });
  });
}
