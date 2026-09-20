---
name: cv-models
description: >-
  Use when defining, reading, writing or serializing data models with
  package:cv (CvModelBase, CvField, CvModelField, CvModelListField,
  cvAddConstructor, toMap/fromMap, toJson/cv<T>()). Covers field declaration,
  null vs unset semantics, builder registration, nested models, lists, enums,
  DateTime encoding and JSON helpers, without code generation.
---

# cv models

`package:cv` maps Dart objects to `Map<String, Object?>` and back with no code
generation. A model is a class whose fields are `CvField` objects. The field
holds the serialized key and a mutable value. The model lists its fields once
and gets `toMap()`, `fromMap()`, `==`, `clone()`, `copyFrom()` and JSON for free.

## Guidelines

* Extend `CvModelBase`. Declare each field as `final x = CvField<T>('key');`
  and override `CvFields get fields => [...]` listing every field. A field not
  in `fields` is never serialized.
* Read and write values through the field: `model.title.v` (alias `.value`).
  Use `.valueOrThrow` when a value is required, `.valueOrNull` when optional.
* Distinguish unset from null. An unset field is absent from `toMap()`. A field
  set to null with `.v = null` is present with a null value. `setValue(null)`
  unsets unless `presentIfNull: true`. `clear()` unsets. `hasValue` is true for
  present values, including null. `isNull` is true for both unset and null.
* `fromMap()` merges: only keys present in the map are written, other fields
  keep their value. Call `clear()` first, or build a new object with
  `map.cv<T>()`, when you need a full replacement.
* Register every model once with `cvAddConstructor(MyModel.new)` (or
  `cvAddConstructors([...])`) before calling `map.cv<T>()`,
  `json.cv<T>()`, `cvNewModel<T>()` or `clone()`. A missing registration throws
  `CvBuilderException` with "Missing builder for 'T'". Group registrations in
  an idempotent `initXxxBuilders()` function per package.
* Field types must be `String`, `int`, `double`, `num`, `bool`, `DateTime`,
  `List`, `Map`, an enum or another `CvModel`. Use `CvListField<T>` for lists
  of basic types, `CvModelField<T>` for one nested model, `CvModelListField<T>`
  for a list of models and `CvModelMapField<T>` for a `Map<String, T>` of
  models. Nested model types need a registered constructor too.
* Numbers read from a map are coerced to the field type (`1.7` into
  `CvField<int>` gives `2`, `1` into `CvField<double>` gives `1.0`).
* Use `CvField.encodedEnum('key', MyEnum.values)` to store an enum as its
  name string, and `CvField.encodedDateTime('key')` to store a `DateTime` as
  an ISO 8601 string. A plain `CvField<DateTime>` keeps the `DateTime` object
  in the map, which is fine for sembast or Firestore but not for JSON.
* Import `package:cv/cv_json.dart` (re-exports `cv.dart`) to get `toJson()`,
  `toJsonPretty()`, `String.cv<T>()` and `String.cvList<T>()`.
* Equality (`==`) and `cvModelsAreEquals` compare `toMap()` content deeply, so
  two models with the same values are equal.
* Prefer `CvFields` (a `List<CvField>`) as the type of `fields`.
* Put derived helpers in an `extension MyModelExt on MyModel` rather than in
  the class, and keep the class limited to field declarations.

## Examples

### Define a model and convert it

```dart
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
  // {title: My note, content: My note context, date: 2021-08-16 00:00:00.000}

  note = Note()..fromMap({'title': 'Other'});
  print(note.title.v); // Other
  print(note.content.hasValue); // false
}
```

### Register constructors and build from a map

```dart
void initNoteBuilders() {
  cvAddConstructor(Note.new);
}

void main() {
  initNoteBuilders();
  var note = {'title': 'My note'}.cv<Note>();
  var notes = [<String, Object?>{'title': 'a'}, {'title': 'b'}].cv<Note>();
  var empty = cvNewModel<Note>();
  var copy = note.clone();
}
```

### Nested models and lists

```dart
class Point extends CvModelBase {
  final x = CvField<int>('x');
  final y = CvField<int>('y');

  @override
  CvFields get fields => [x, y];
}

class Shape extends CvModelBase {
  final origin = CvModelField<Point>('origin');
  final points = CvModelListField<Point>('points');
  final tags = CvListField<String>('tags');
  final named = CvModelMapField<Point>('named');

  @override
  CvFields get fields => [origin, points, tags, named];
}

void main() {
  cvAddConstructors([Point.new, Shape.new]);
  var shape = {
    'origin': {'x': 0, 'y': 0},
    'points': [
      {'x': 1, 'y': 2},
      {'x': 3, 'y': 4},
    ],
    'tags': ['a', 'b'],
  }.cv<Shape>();
  print(shape.points.v![1].y.v); // 4

  // Building nested content in code
  shape.origin.v = Point()
    ..x.v = 10
    ..y.v = 20;
  shape.points.v = [Point()..x.v = 1];
  // Or create an empty child through the field:
  var child = shape.points.create({})..x.v = 5;
  shape.points.v!.add(child);
}
```

### Enum and DateTime encoded for JSON

```dart
enum Status { draft, published }

class Article extends CvModelBase {
  final status = CvField.encodedEnum('status', Status.values);
  final createdAt = CvField.encodedDateTime('createdAt');

  @override
  CvFields get fields => [status, createdAt];
}

void main() {
  cvAddConstructor(Article.new);
  var article = Article()
    ..status.v = Status.published
    ..createdAt.v = DateTime.utc(2024, 1, 2);
  print(article.toMap());
  // {status: published, createdAt: 2024-01-02T00:00:00.000Z}
  print(article.status.v); // Status.published
}
```

### JSON

```dart
import 'package:cv/cv_json.dart';

void main() {
  cvAddConstructor(Note.new);
  var note = '{"title":"My note"}'.cv<Note>();
  var notes = '[{"title":"a"},{"title":"b"}]'.cvList<Note>();
  print(note.toJson()); // {"title":"My note"}
  print(notes.toJson()); // [{"title":"a"},{"title":"b"}]
  print(note.toJsonPretty());
}
```

### Null, unset and partial maps

```dart
var note = Note();
note.toMap(); // {}
note.title.v = null;
note.toMap(); // {title: null}
note.title.setValue(null);
note.toMap(); // {}
note.toMap(includeMissingValue: true); // {title: null, content: null, date: null}

// Only export or import some columns
var map = <String, Object?>{'title': 'Other', 'content': 'Body'};
var otherNote = Note();
note.toMap(columns: ['title']);
note.fromMap(map, columns: ['title', 'content']);
note.copyFrom(otherNote, columns: ['title']);
```

### Reuse fields through a mixin

```dart
mixin TimestampsMixin on CvModelBase {
  final createdAt = CvField.encodedDateTime('createdAt');
  final updatedAt = CvField.encodedDateTime('updatedAt');

  CvFields get timestampFields => [createdAt, updatedAt];
}

class Post extends CvModelBase with TimestampsMixin {
  final title = CvField<String>('title');

  @override
  CvFields get fields => [title, ...timestampFields];
}
```

## Common mistakes

* Forgetting to add a new field to `fields`. It silently stays out of the map.
* Calling `map.cv<T>()` before `cvAddConstructor(T.new)`.
* Mixing base classes in one `cvAddConstructors` call. Register `CvModelBase`
  models and `CvMapModelBase` models in separate calls.
* Expecting `fromMap()` to reset fields absent from the map.
* Using `CvField<DateTime>` in a model that is sent as JSON. Use
  `CvField.encodedDateTime` instead.
* Declaring a field as `CvField<MyModel>`. Use `CvModelField<MyModel>` so the
  nested map is converted.

## More

See [references/advanced.md](references/advanced.md) for `CvMapModelBase`
(models that keep unknown keys), raw `Model` map helpers, tree paths
(`cvPath`, `cvTreeValueAtPath`), `withParent` flattened keys, multi-type
fields, and the test helpers in `package:cv/cv_matcher.dart` (`cvEquals`,
`cvEqualsDiffReport`, `fillModel`).
