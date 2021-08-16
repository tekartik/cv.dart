import 'package:cv/cv.dart';
import 'package:test/test.dart';

import 'note_model.dart';

void main() {
  group('doc', () {
    test('toMap', () {
      var note = Note()
        ..title.v = 'My note'
        ..content.v = 'My note context'
        ..date.v = DateTime(2021, 08, 16);
      expect(note.toMap(), {
        'title': 'My note',
        'content': 'My note context',
        'date': DateTime(2021, 08, 16)
      });
    });

    test('fromMap', () {
      var note = Note();
      note.fromMap({
        'title': 'My note',
        'content': 'My note context',
        'date': DateTime(2021, 08, 16)
      });
      expect(note.title.v, 'My note');
    });
    test('cv', () {
// Add the builder once
      cvAddBuilder<Note>((_) => Note());

// Any map can be converted to a note object
      var note = {'title': 'My note'}.cv<Note>();
      expect(note.title.v, 'My note');
    });
  });
}
