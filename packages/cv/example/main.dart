// ignore_for_file: avoid_print

import 'package:cv/cv.dart';

class Note extends CvModelBase {
  final title = CvField<String>('title');
  final content = CvField<String>('content');
  final date = CvField<DateTime>('date');

  @override
  CvFields get fields => [title, content, date];
}

void main() {
  var note = Note()
    ..title.v = 'My note'
    ..content.v = 'My note context'
    ..date.v = DateTime(2021, 08, 16);
  print(note.toMap());

  note = Note()
    ..fromMap({
      'title': 'My other note',
      'content': 'My other note context',
      'date': DateTime(2021, 08, 18),
    });
  print(note.toMap());

  // Add the builder once
  cvAddBuilder<Note>((_) => Note());

  // Any map can be converted to a note object
  note = {'title': 'My note from a map'}.cv<Note>();
  print(note.toMap());

  note = {
    'title': 'My other note from a map',
    'content': 'With some content',
  }.cv<Note>();
  print(note.toMap());
}
