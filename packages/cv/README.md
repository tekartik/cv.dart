# cv

Content Values map helpers: convert Dart objects to `Map<String, Object?>` (and
JSON) and back, without code generation. A model lists its fields once and
gets `toMap()`, `fromMap()`, `==`, `clone()` and JSON helpers.

## Getting started

Add the dependency:

```sh
dart pub add cv
```

Define a model, register it once, then convert:

```dart
import 'package:cv/cv_json.dart';

class Todo extends CvModelBase {
  final title = CvField<String>('title');
  final done = CvField<bool>('done');

  /// Every field of the model: a field missing here is ignored.
  @override
  CvFields get fields => [title, done];
}

void main() {
  // Once, before map.cv<Todo>(), json.cv<Todo>() or clone().
  cvAddConstructor(Todo.new);

  var todo = Todo()..title.v = 'Buy milk';
  print(todo.toMap()); // {title: Buy milk}
  print(todo.toJson()); // {"title":"Buy milk"}

  todo = {'title': 'Call Bob', 'done': true}.cv<Todo>();
  print(todo.done.v); // true

  todo = '{"title":"Read"}'.cv<Todo>();
  print(todo.title.v); // Read
}
```

`package:cv/cv_json.dart` exports `package:cv/cv.dart` and adds the JSON
helpers.

### Which field to use

| Value                                                   | Field                                        |
|---------------------------------------------------------|----------------------------------------------|
| `String`, `int`, `double`, `num`, `bool`, `Map`, `List` | `CvField<T>('key')`                          |
| a list of basic values                                  | `CvListField<T>('key')`                      |
| a nested model                                          | `CvModelField<T>('key')`                     |
| a list of models                                        | `CvModelListField<T>('key')`                 |
| a `Map<String, T>` of models                            | `CvModelMapField<T>('key')`                  |
| a `DateTime` stored as an ISO 8601 string               | `CvField.encodedDateTime('key')`             |
| an enum stored as its name                              | `CvField.encodedEnum('key', MyEnum.values)`  |
| one value of one of two types                           | `CvMultiField2(CvField<String>('key'), CvField<int>('key'))` |

A plain `CvField<DateTime>` keeps the `DateTime` object in the map: `toJson()`
throws on it. Use `CvField.encodedDateTime` for JSON.

### Common mistakes

* A field missing from `fields` is ignored by `toMap()`, `fromMap()` and `==`,
  without any error.
* Register each model type with `cvAddConstructor(MyModel.new)` (or
  `cvAddConstructors([A.new, B.new])`) before `map.cv<T>()`, `json.cv<T>()`,
  `cvNewModel<T>()` or `clone()`. The model types nested in a `CvModelField`,
  `CvModelListField` or `CvModelMapField` must be registered too, even for
  `fromMap()` on an object you created. Otherwise a `CvBuilderException`
  (`Missing builder for 'T'`) is thrown. A list from `mapList.cv<T>()` is lazy:
  the exception comes when an item is read.
* `field.v` is `null` both when the field is not set and when it is set to
  `null`. `hasValue` tells them apart: a field that is not set is absent from
  `toMap()`, a field set to `null` (`v = null`) is written as `key: null`.
* `fromMap()` merges: the keys absent from the map keep their value. Call
  `clear()` first, or create a new object with `map.cv<T>()`.
* `fromMap()` does not throw on bad data: a value that cannot be converted to
  the field type is skipped. Basic types are converted when possible (`1.7`
  gives `2` in an `int` field, `'12'` gives `12`).
* Declare a nested model as `CvModelField<T>`, not `CvField<T>`, otherwise the
  nested map is not converted.
* Two fields of a model cannot have the same key (it throws in debug mode).

## Features

- Object to Map conversion
- Map to Object conversion
- No code generation
- All objects are mutable
- Deals with null and undefined values
- Field type is final and strongly enforced
- All fields have final key and mutable values

Drawbacks:
- A field value must be accessed through a getter (`value` or `v`)

## Usage

A model is defined by its fields:

```dart
import 'package:cv/cv.dart';

class Note extends CvModelBase {
  final title = CvField<String>('title');
  final content = CvField<String>('content');
  final date = CvField<DateTime>('date');

  /// List of the fields of the model
  @override
  CvFields get fields => [title, content, date];
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
  'date': DateTime(2021, 08, 16),
});
```

and from a map:

```dart
var note = Note();
note.fromMap({
  'title': 'My note',
  'content': 'My note context',
  'date': DateTime(2021, 08, 16),
});
expect(note.title.v, 'My note');
```

For convenience, extension on Map are created to simply call `.cv<Type>()` on map to convert them to object:

```dart
// Add the builder once
cvAddConstructor(Note.new);

// Any map can be converted to a note object
var note = {'title': 'My note'}.cv<Note>();
expect(note.title.v, 'My note');
```

## Null and unset values

```dart
var note = Note();
note.title.hasValue; // false: not set
note.toMap(); // {}
note.title.v = null;
note.title.hasValue; // true: set to null
note.toMap(); // {title: null}
note.title.clear(); // not set again
note.toMap(includeMissingValue: true); // {title: null, content: null, date: null}
```

Use `valueOrThrow` when a value is required.

## Complex object examples

### Inner object

Here is a small example of an object containing other object

```dart
class Rect extends CvModelBase {
  final point = CvModelField<Point>('point');
  final size = CvModelField<Size>('size');

  @override
  CvFields get fields => [point, size];
}

class Point extends CvModelBase {
  final x = CvField<int>('x');
  final y = CvField<int>('y');

  @override
  CvFields get fields => [x, y];
}

class Size extends CvModelBase {
  final width = CvField<int>('width');
  final height = CvField<int>('height');

  @override
  CvFields get fields => [width, height];
}
```

```dart
// Add the builders (needed only once)
cvAddConstructors([Rect.new, Point.new, Size.new]);
```

```dart
// Any map can be converted to a rect object
var rect = {
  'point': {'x': 100, 'y': 50},
  'size': {'width': 300, 'height': 200},
}.cv<Rect>();
var size = rect.size.v!;
expect(size.width.v, 300);

// and you can convert your object to a map
print(rect.toMap());
// {point: {x: 100, y: 50}, size: {width: 300, height: 200}}
```

### Inner object list

```dart
class ShoppingCart extends CvModelBase {
  final items = CvModelListField<Item>('items');

  @override
  CvFields get fields => [items];
}

class Item extends CvModelBase {
  final name = CvField<String>('name');
  final price = CvField<int>('price');

  @override
  CvFields get fields => [name, price];
}
```

```dart
// Add the builders (once)
cvAddConstructors([ShoppingCart.new, Item.new]);
```

```dart
// Any map can be converted to a cart object
var cart = {
  'items': [
    {'name': 'Chair', 'price': 50},
    {'name': 'Lamp', 'price': 12},
  ],
}.cv<ShoppingCart>();
var items = cart.items.v!;
expect(items[0].name.v, 'Chair');

print(cart.toMap());
// {items: [{name: Chair, price: 50}, {name: Lamp, price: 12}]}
```

## Json

Additional json helpers extension on string are available if you include:

```dart
import 'package:cv/cv_json.dart';
```

Using `.cv()` you can decode a single object:

```dart
var cartJson =
    '{"items":[{"name":"Chair","price":50},{"name":"Lamp","price":12}]}';

// Create a cart object
var cart = cartJson.cv<ShoppingCart>();
```

Using `.cvList()`, a list of object:

```dart
var itemsJson = '[{"name":"Chair","price":50},{"name":"Lamp","price":12}]';

/// Create a list of objects
var items = itemsJson.cvList<Item>();
```

and you can encode to json both lists and objects using `toJson()`:

```dart
print(cart.toJson());
// {"items":[{"name":"Chair","price":50},{"name":"Lamp","price":12}]}

print(items.toJson());
// [{"name":"Chair","price":50},{"name":"Lamp","price":12}]
```

## More

The [advanced guide](https://github.com/tekartik/cv.dart/blob/main/packages/cv/skills/cv-models/references/advanced.md)
covers `CvMapModelBase` (models that keep unknown keys), builders that pick a
subclass, `withParent` flattened keys, paths into the tree, multi-type fields,
raw map helpers and the test helpers of `package:cv/cv_matcher.dart`.

## Why

- Relying on code generator always adds a level of build complexity (and build failure risk).
- No setup needed other than adding the package
- Having mutable values can lead to more mistakes though. But well, you know what your are doing and it is convenient
- In Java, I used to like ContentValues in Android, having a little more control than a regular HashMap.
- In Java, I also used to like Gson for its simplicity: just define a class.
