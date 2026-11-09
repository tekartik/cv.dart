// ignore_for_file: avoid_print

import 'package:cv/cv_json.dart';

/// A model: its fields, all listed in [fields].
class Note extends CvModelBase {
  final title = CvField<String>('title');
  final content = CvField<String>('content');
  final date = CvField<DateTime>('date');

  @override
  CvFields get fields => [title, content, date];
}

/// A nested model and a list of models.
class Folder extends CvModelBase {
  final name = CvField<String>('name');
  final owner = CvModelField<Person>('owner');
  final members = CvModelListField<Person>('members');
  final tags = CvListField<String>('tags');

  @override
  CvFields get fields => [name, owner, members, tags];
}

class Person extends CvModelBase {
  final name = CvField<String>('name');

  @override
  CvFields get fields => [name];
}

void main() {
  // Register the model types once, nested ones included, before converting
  // maps or JSON to objects.
  cvAddConstructors([Note.new, Folder.new, Person.new]);

  // Object to map.
  var note = Note()
    ..title.v = 'My note'
    ..content.v = 'My note context'
    ..date.v = DateTime(2021, 08, 16);
  print(note.toMap());
  // {title: My note, content: My note context, date: 2021-08-16 00:00:00.000}

  // Map to object, on an existing object...
  note = Note()
    ..fromMap({
      'title': 'My other note',
      'content': 'My other note context',
      'date': DateTime(2021, 08, 18),
    });
  print(note.toMap());

  // ...or creating it (needs the registration above).
  note = {'title': 'My note from a map'}.cv<Note>();
  print(note.toMap()); // {title: My note from a map}

  // Not set vs set to null.
  print(note.content.hasValue); // false
  note.content.v = null;
  print(note.content.hasValue); // true
  print(note.toMap()); // {title: My note from a map, content: null}

  // Nested models and lists, from and to JSON.
  var json =
      '{"name":"Work","owner":{"name":"Ann"},'
      '"members":[{"name":"Bob"},{"name":"Cid"}],"tags":["a","b"]}';
  var folder = json.cv<Folder>();
  print(folder.owner.v!.name.v); // Ann
  print(folder.members.v![1].name.v); // Cid
  folder.members.v!.add(Person()..name.v = 'Dan');
  print(folder.toJson());
  // {"name":"Work","owner":{"name":"Ann"},"members":[{"name":"Bob"},{"name":"Cid"},{"name":"Dan"}],"tags":["a","b"]}
}
