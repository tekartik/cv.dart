import 'package:cv/cv.dart';
import 'package:cv/cv_matcher.dart';
import 'package:test/test.dart';

class MatcherSimple extends CvModelBase {
  final value1 = CvField<String>('value1');
  final value2 = CvField<String>('value2');

  @override
  CvFields get fields => [value1, value2];
}

class MatcherComplex extends CvModelBase {
  final simple1 = CvField<MatcherSimple>('simple1');
  final value1 = CvField<String>('value1');
  final value2 = CvField<String>('value2');

  @override
  CvFields get fields => [value1, value2];
}

void main() {
  test('matcher', () {
    cvAddConstructors([MatcherSimple.new, MatcherComplex.new]);
    expect(
        MatcherSimple,
        fillModelMatchesMap(
            {'value1': 'text_1', 'value2': 'text_2'}, cvFillOptions1));

    expect(
        MatcherSimple, fillModelMatchesMap({'value1': null, 'value2': null}));
    expect(
        MatcherSimple, fillModelMatchesMap({'value2': null, 'value1': null}));
    expect(MatcherSimple,
        isNot(fillModelMatchesMap({'value2': null, 'value3': null})));

// Debug it first
    expect(MatcherSimple, isNot(fillModelMatchesMap({'value2': null})));

    expect(
        MatcherSimple,
        fillModelMatchesMap(
            {'value2': 'text_2', 'value1': 'text_1'}, cvFillOptions1));
  });
}
