import 'package:cv/cv.dart';
import 'package:cv/cv_matcher.dart';
import 'package:test/test.dart';

class MatcherSimple extends CvModelBase {
  final value1 = CvField<String>('value1');
  final value2 = CvField<String>('value2');

  @override
  CvFields get fields => [value1, value2];
}

class MatcherListComplex extends CvModelBase {
  final simples = CvModelListField<MatcherSimple>('simples');
  final value1 = CvField<String>('c1');
  final value2 = CvField<String>('c2');

  @override
  CvFields get fields => [simples, value1, value2];
}

class MatcherComplex extends CvModelBase {
  final simple1 = CvModelField<MatcherSimple>('simple1');
  final value1 = CvField<String>('c1');
  final value2 = CvField<String>('c2');

  @override
  CvFields get fields => [simple1, value1, value2];
}

class MatcherSuperComplex extends CvModelBase {
  final complex1 = CvModelField<MatcherComplex>('complex1');
  final value1 = CvField<String>('s1');
  final value2 = CvField<String>('s2');

  @override
  CvFields get fields => [complex1, value1, value2];
}

void main() {
  test('matcher simple', () {
    cvAddConstructors([MatcherSimple.new, MatcherComplex.new]);

    expect(
      MatcherSimple,
      fillModelMatchesMap({'value1': null, 'value2': null}),
    );
    expect(
      MatcherSimple,
      fillModelMatchesMap({'value2': null, 'value1': null}),
    );
    expect(
      MatcherSimple,
      isNot(fillModelMatchesMap({'value2': null, 'value3': null})),
    );

    // Debug it first
    expect(MatcherSimple, isNot(fillModelMatchesMap({'value2': null})));
    expect(
      MatcherSimple,
      fillModelMatchesMap({
        'value2': 'text_1',
        'value1': 'text_2',
      }, cvFillOptions1),
    );
    expect(
      MatcherSimple,
      fillModelMatchesMap({
        'value1': 'text_1',
        'value2': 'text_2',
      }, cvFillOptions1),
    );
  });
  test('matcher complex', () {
    cvAddConstructors([MatcherSimple.new, MatcherComplex.new]);
    expect(
      MatcherComplex,
      fillModelMatchesMap({
        'c1': 'text_1',
        'simple1': {'value1': 'text_2', 'value2': 'text_3'},
        'c2': 'text_4',
      }, cvFillOptions1),
    );
    expect(
      MatcherComplex,
      isNot(
        fillModelMatchesMap({
          'c1': 'text_2',
          'simple1': {'value1': 'text_2', 'value2': 'text_3'},
          'c2': 'text_4',
        }, cvFillOptions1),
      ),
    );
    expect(
      MatcherComplex,
      fillModelMatchesMap({
        'simple1': {'value1': 'text_1', 'value2': 'text_2'},
        'c1': 'text_3',
        'c2': 'text_4',
      }, cvFillOptions1),
    );
    expect((cvNewModel<MatcherComplex>()..fillModel(cvFillOptions1)).toMap(), {
      'c1': 'text_3',
      'simple1': {'value1': 'text_1', 'value2': 'text_2'},
      'c2': 'text_4',
    });
  });
  test('matcher super complex', () {
    cvAddConstructors([
      MatcherSimple.new,
      MatcherComplex.new,
      MatcherSuperComplex.new,
    ]);
    expect(
      MatcherSuperComplex,
      fillModelMatchesMap({
        's1': 'text_1',
        'complex1': {
          'c2': 'text_2',
          'simple1': {'value2': 'text_3', 'value1': 'text_4'},
          'c1': 'text_5',
        },
        's2': 'text_6',
      }, cvFillOptions1),
    );
    expect(
      MatcherSuperComplex,
      fillModelMatchesMap({
        'complex1': {
          'simple1': {'value1': 'text_1', 'value2': 'text_2'},
          'c1': 'text_3',
          'c2': 'text_4',
        },
        's1': 'text_5',
        's2': 'text_6',
      }, cvFillOptions1),
    );
  });
  test('matcher list complex', () {
    cvAddConstructors([MatcherSimple.new, MatcherListComplex.new]);

    expect(
      MatcherListComplex,
      fillModelMatchesMap({
        'c1': 'text_1',
        'simples': [
          {'value2': 'text_2', 'value1': 'text_3'},
        ],
        'c2': 'text_4',
      }, cvFillOptions1),
    );
    expect(
      MatcherListComplex,
      fillModelMatchesMap({
        'simples': [
          {'value1': 'text_1', 'value2': 'text_2'},
        ],
        'c1': 'text_3',
        'c2': 'text_4',
      }, cvFillOptions1),
    );
  });
}
