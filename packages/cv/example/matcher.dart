// ignore_for_file: avoid_print

import 'package:cv/cv.dart';
import 'package:cv/cv_matcher.dart';

import 'main.dart';

void main() {
  var note = Note()..title.v = 'My note';
  var note2 = Note()..fromMap({'title': 'My other note'});
  var note3 = Note()
    ..copyFrom(note)
    ..content.v = 'Some content'
    ..date.v = DateTime(2025, 04, 04);

  void report(Object? value, Object? expected) {
    print('value: $value');
    print('expec: $expected');
    var report = cvEqualsDiffReport(value, expected);
    print('report: $report\n');
  }

  report(note, note);
  report(note, note2);
  report(note, note3);
  report(note2, note3);
}
