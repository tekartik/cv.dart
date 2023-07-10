# cv

Content Values map helpers.

These helpers are about mapping map fields to named fields and vice versa. Key features:
- Object to Map conversion
- Map to Object conversion
- No code generation
- All objects are mutable
- Deals with null and undefined values
- Field type is final and strongly enforced
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

For convenience, extension on Map are created to simply call `.cv<Type>()` on map to convert them to object:
```dart
// Add the builder once (requires dart 2.15 - use cvAddBuilder otherwise)
cvAddConstructor(Note.new);

// Any map can be converted to a note object
var note = {'title': 'My note'}.cv<Note>();
expect(note.title.v, 'My note');
```

## Complex object examples

### Inner object

Here is a small example of an object containing other object

```dart
class Rect extends CvModelBase {
  final point = CvModelField<Point>('point');
  final size = CvModelField<Size>('size');

  @override
  List<CvField> get fields => [point, size];
}

class Point extends CvModelBase {
  final x = CvField<int>('x');
  final y = CvField<int>('y');

  @override
  List<CvField> get fields => [x, y];
}

class Size extends CvModelBase {
  final width = CvField<int>('width');
  final height = CvField<int>('height');

  @override
  List<CvField> get fields => [width, height];
}
```

```dart
// Add the builders once
cvAddConstructor(Rect.new);
cvAddConstructor(Point.new);
cvAddConstructor(Size.new);
```

```dart
// Any map can be converted to a rect object
var rect = {
  'point': {'x': 100, 'y': 50},
  'size': {'width': 300, 'height': 200}
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
  List<CvField> get fields => [items];
}

class Item extends CvModelBase {
  final name = CvField<String>('name');
  final price = CvField<int>('price');

  @override
  List<CvField> get fields => [name, price];
}
```

```dart
// Add the builders once
cvAddConstructor(Cart.new);
cvAddConstructor(Item.new);
```

```dart
// Any map can be converted to a cart object
var cart = {
  'items': [
    {'name': 'Chair', 'price': 50},
    {'name': 'Lamp', 'price': 12}
  ]
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
var itemsJson =
    '[{"name":"Chair","price":50},{"name":"Lamp","price":12}]';

/// Create a list of objects
var items = itemsJson.cvList<Item>();
```

and you can encode to json both lists and objects using `toJson()`:

```dart
print(cart.toJson());
// {items: [{name: Chair, price: 50}, {name: Lamp, price: 12}]}

print(items.toJson());
// [{"name":"Chair","price":50},{"name":"Lamp","price":12}]
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
      url: https://github.com/tekartik/cv.dart
      ref: dart3a
      path: packages/cv
    version: '>=0.1.0'
```