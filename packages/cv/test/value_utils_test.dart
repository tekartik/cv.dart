import 'package:cv/utils/value_utils.dart';
import 'package:test/test.dart';

void main() {
  var now = DateTime.now();
  group('value_utils', () {
    test('basicTypeCast<any>', () {
      for (var value in [
        null,
        now,
        'dummy',
        0,
        '0',
        1,
        '1',
        2,
        '2',
        true,
        false,
        int,
        1.1,
        1.9,
        '1.1',
        '-1.1',
        '-1.9',
        '1.9',
        '3notyetstartingwithnumberbutcouldchangeandthatsok'
      ]) {
        var intExpected = basicTypeToInt(value);
        expect(basicTypeCast<int>(value), intExpected);
        expect(basicTypeCastType(int, value), intExpected);
        var numExpected = basicTypeToNum(value);
        expect(basicTypeCast<num>(value), numExpected);
        expect(basicTypeCastType(num, value), numExpected);
        var boolExpected = basicTypeToBool(value);
        expect(basicTypeCast<bool>(value), boolExpected);
        expect(basicTypeCastType(bool, value), boolExpected);
        var doubleExpected = basicTypeToDouble(value);
        expect(basicTypeCast<double>(value), doubleExpected);
        expect(basicTypeCastType(double, value), doubleExpected);
      }
    });
    test('basicTypeToInt', () {
      expect(basicTypeToInt(1.1), 1);
      expect(basicTypeToInt('1.1'), 1);
      expect(basicTypeToInt(''), isNull);
      expect(basicTypeToInt(1.9), 2);
      expect(basicTypeToInt('1.9'), 2);
      expect(basicTypeToInt(1.1), 1);
      expect(basicTypeToInt(1.9), 2);
      expect(basicTypeToInt(null), isNull);
      expect(basicTypeToInt(now), isNull);
      expect(basicTypeToInt('dummy'), isNull);
      expect(basicTypeToInt(0), 0);
      expect(basicTypeToInt('0'), 0);
      expect(basicTypeToInt(1), 1);
      expect(basicTypeToInt('1'), 1);
      expect(basicTypeToInt(-1), -1);
      expect(basicTypeToInt('-1'), -1);
      expect(basicTypeToInt(2), 2);
      expect(basicTypeToInt('2'), 2);
      expect(basicTypeToInt(true), 1);
      expect(basicTypeToInt(false), 0);
      expect(basicTypeToInt(1.1), 1);
      expect(basicTypeToInt('1.1'), 1);
      expect(basicTypeToInt(-1.1), -1);
      expect(basicTypeToInt('-1.1'), -1);
      expect(basicTypeToInt(-1.9), -2);
      expect(basicTypeToInt('-1.9'), -2);
      expect(
          basicTypeToInt('3notyetstartingwithnumberbutcouldchangeandthatsok'),
          isNull);
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
