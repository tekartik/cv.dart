# cv

Content Values map helpers.

These helpers are about helping mapping map fields to named fields. Key features:
- Object to Map conversion
- Map to Object conversion
- No code generation
- All objects are mutable
- Deals with null and undefined values

## Usage

A model can define by defining fields in the following way:

```dart
import 'package:cv/cv.dart';

class Note extends CvModelBase {
  final title = CvField<String>('title');
  final content = CvField<String>('content');
  final date = CvField<DateTime>('date');

  @override
  /// List of the fields of the model
  List<CvField> get fields => [title, content, date];
}
```

You can convert the object to a map:

```dart
var note = Note()
  ..title.v = 'My note'
  ..content.v = 'My note context'
  ..date.v = DateTime(2021, 08, 16);
expect(note.toMap(), {
  'title': 'My note',
  'content': 'My note context',
  'date': DateTime(2021, 08, 16)
});
```

and from a map:

```dart
var note = Note();
note.fromMap({
  'title': 'My note',
  'content': 'My note context',
  'date': DateTime(2021, 08, 16)
});
expect(note.title.v, 'My note');
```

For convenience, extension on Map are created to simple call `.cv<Type>()` on map to convert them to object:
```dart
// Add the builder once
cvAddBuilder<Note>((_) => Note());

// Any map can be converted to a note object
var note = {'title': 'My note'}.cv<Note>();
expect(note.title.v, 'My note');
```
