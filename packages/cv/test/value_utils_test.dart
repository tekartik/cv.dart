import 'package:cv/src/utils.dart';
import 'package:test/test.dart';

void main() {
  var now = DateTime.now();
  group('value_utils', () {
    test('basicTypeCast<int>', () {
      expect(basicTypeCast<int>(null), isNull);
      expect(basicTypeCast<int>(now), isNull);
      expect(basicTypeCast<int>('dummy'), isNull);
      expect(basicTypeCast<int>(0), 0);
      expect(basicTypeCast<int>('0'), 0);
      expect(basicTypeCastType(int, '0'), 0);
      expect(basicTypeCast<int>(1), 1);
      expect(basicTypeCast<int>('1'), 1);
      expect(basicTypeCast<int>(2), 2);
      expect(basicTypeCast<int>('2'), 2);
      expect(basicTypeCast<int>(true), 1);
      expect(basicTypeCast<int>(1.1), 1);
      expect(basicTypeCast<int>('1.1'), 1);
    });
    test('basicTypeCast<num>', () {
      expect(basicTypeCast<num>(null), isNull);
      expect(basicTypeCast<num>(now), isNull);
      expect(basicTypeCast<num>('dummy'), isNull);
      expect(basicTypeCast<num>(1), 1);
      expect(basicTypeCast<num>('1'), 1);
      expect(basicTypeCastType(num, '1'), 1);
      expect(basicTypeCast<num>(true), 1);
      expect(basicTypeCast<num>(1.1), 1.1);
      expect(basicTypeCast<num>('1.1'), 1.1);
    });
    test('basicTypeCast<double>', () {
      expect(basicTypeCast<double>(null), isNull);
      expect(basicTypeCast<double>(now), isNull);
      expect(basicTypeCast<double>('dummy'), isNull);
      expect(basicTypeCast<double>(1), 1.0);
      expect(basicTypeCastType(double, '1'), 1.0);
      expect(basicTypeCast<double>('1'), 1.0);
      expect(basicTypeCast<double>(true), 1.0);
      expect(basicTypeCast<double>(1.1), 1.1);
      expect(basicTypeCast<double>('1.1'), 1.1);
    });
    test('basicTypeCast<String>', () {
      expect(basicTypeCast<String>(null), isNull);

      expect(basicTypeCast<String>(now), now.toString());
      expect(basicTypeCast<String>('dummy'), 'dummy');
      expect(basicTypeCastType(String, 'dummy'), 'dummy');
      expect(basicTypeCast<String>(1), '1');
      expect(basicTypeCast<String>('1'), '1');
      expect(basicTypeCast<String>(true), 'true');
      expect(basicTypeCast<String>(1.1), '1.1');
      expect(basicTypeCast<String>('1.1'), '1.1');
    });
    test('basicTypeCast<bool>', () {
      expect(basicTypeCast<bool>(null), isNull);

      expect(basicTypeCast<bool>(now), isNull);
      expect(basicTypeCast<bool>('dummy'), isNull);
      expect(basicTypeCast<bool>('true'), true);
      expect(basicTypeCastType(bool, 'true'), true);
      expect(basicTypeCast<bool>('false'), false);
      expect(basicTypeCast<bool>(0), false);
      expect(basicTypeCast<bool>('0'), false);
      expect(basicTypeCast<bool>(1), true);
      expect(basicTypeCast<bool>('1'), true);
      expect(basicTypeCast<bool>(2), true);
      expect(basicTypeCast<bool>('2'), true);
      expect(basicTypeCast<bool>(true), true);
      expect(basicTypeCast<bool>(1.1), true);
      expect(basicTypeCast<bool>('1.1'), true);
    });
  });
}
