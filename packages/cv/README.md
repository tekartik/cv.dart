# cv

Content Values map helpers.

These helpers are about mapping map fields to named fields and vice versa. Key features:
- Object to Map conversion
- Map to Object conversion
- No code generation
- All objects are mutable
- Deals with null and undefined values
- Field type if final and strongly enforced
- All fields have final key and mutable values

Drawbacks:
- A field value must be access through a getter (`value` or `v`)

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

## Why

- Relying on code generator always adds a level of build complexity (and build failure risk).
- No setup needed other than adding the package
- Having mutable values can lead to more mistakes though. But well, you know what your are doing and it is convenient
- In Java, I used to like ContentValues in Android, having a little more control than a regular HashMap.
- In Java, I also used to like Gson for its simplicity: just define a class.

## Git setup

## Usage

In your `pubspec.yaml`:

```yaml
dependencies:
  cv:
    git:
      url: git://github.com/tekartik/cv.dart
      ref: null_safety
      path: packages/cv
    version: '>=0.1.0'
```