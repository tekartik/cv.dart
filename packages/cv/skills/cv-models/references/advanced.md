# cv advanced APIs

Everything here is exported by `package:cv/cv.dart` unless stated otherwise.

## CvMapModelBase: typed fields plus unknown keys

Use when a document has a few known fields and an open set of other keys.
Declare the typed fields in `modelFields` (not `fields`). The object is also a
`Map<String, Object?>`. Unknown keys read from a map are kept and written back.

```dart
class Bag extends CvMapModelBase {
  final name = CvField<String>('name');

  @override
  CvFields get modelFields => [name];
}

var bag = Bag()..fromMap({'name': 'n', 'extra': 1});
bag.name.v; // 'n'
bag['extra']; // 1
bag['other'] = true;
bag.toMap(); // {name: n, extra: 1, other: true}
```

`CvMapModel()` is the untyped version, a `CvModel` that behaves as a plain map.
Register `CvMapModelBase` subclasses with their own `cvAddConstructors` call,
separate from `CvModelBase` subclasses.

## Builders that pick a subclass

`cvAddConstructor` is enough for plain models. When the concrete class depends
on the data, register a builder that receives the source map. The builder must
only create the object, `cv` fills it afterwards.

```dart
abstract class Animal extends CvModelBase {
  final type = CvField<String>('type');
  @override
  CvFields get fields => [type];
}
class Dog extends Animal {}
class Cat extends Animal {}

cvAddBuilder<Animal>((map) => map['type'] == 'cat' ? Cat() : Dog());
var cat = {'type': 'cat'}.cv<Animal>(); // Cat
```

A one-off builder can also be passed at call time:
`map.cv<Animal>(builder: (_) => Dog())`. `cvTypeAddBuilder`,
`cvTypeBuildModel` and `map.cvType<T>(type)` do the same from a runtime `Type`.

## Nested fields with a custom creator

`CvModelField<T>.builder(name, builder: (_) => T())` and
`CvModelListField<T>.builder(...)` create children without a registered
constructor. `field.create({})` returns a new empty child of the right type.

## Flattened keys with withParent

`CvField<int>('x').withParent('pos')` reads and writes `{'pos': {'x': ...}}`
while staying a scalar field on the model. Its `name` is `pos.x`.

## Lists of models

* `mapList.cv<T>()` on a `List<Map>` returns a lazy list by default. Each
  element is converted on first access. Pass `lazy: false` for an eager list.
* `models.toMapList()` on a `List<CvModel>` mirrors `toMap()`.
* `cvNewModelList<T>()` creates an empty typed list.
* `CvModelListField<T>` values are plain `List<T>`, mutate them in place.

## Paths into the tree

Typed path building, then read or write at that path without touching
intermediate objects:

```dart
var path = parent.cvPath.kids.pathSubAt(1).sub.treePath; // kids.1.sub
var tv = parent.cvTreeValueAtPath<String>(path);
tv.found; // true when every step exists
tv.value; // 'k1'
tv.setValue('changed');
```

`cvPath` returns a template instance whose fields record the path.
`pathSub` (single model), `pathSubAt(index)` (list) and `pathSubAt(key)` (map)
descend one level. `treePathAt(index)` addresses an item of a `CvListField`.

Untyped equivalents take a `List<Object>` of keys and indexes:

* `model.valueAtPath<T>(['kids', 0, 'sub'])` and
  `model.setValueAtPath(['kids', 0, 'sub'], value)`.
* `model.fieldAtPath<T>(parts)` returns the `CvField` at a path.
* On a raw map, `map.getKeyPathValue<T>(parts)`.
* `CvFieldPath` parses a dotted string form, `keyPartsToString` and
  `keyPartsFromString` convert between `'a.b.0'` and `['a', 'b', 0]`.

## Fields accepting several types

`CvMultiField2(CvField<String>('any'), CvField<int>('any'))` holds one of two
typed fields under the same key. `multiFromAnyValue(value)` routes the value to
the matching field, `multiField` and `multiValue` expose the active one.
`CvMultiListField2` does the same for lists whose items may be of two types.
`CvMultiField` and `CvMultiListField` are the base interfaces. Both must use
the same key name.

## Raw map and list helpers

`Model` is `Map<String, Object?>`, `ModelList` is `List<Model>`.

* `newModel()`, `newModelList()`, `asModel(map)`, `asModelList(list)` create or
  cast without copying when the type already matches.
* `map.setValue(key, value)` removes the key when value is null unless
  `presentIfNull: true`. `map.getValue<T>(key)` casts on read.
* `map.deepClone()`, `list.deepClone()` copy nested maps and lists.
* `object.anyAs<T>()` casts any value, including `Map` to `Model`.
* `map.cvOverride(field)`, `map.cvSetNull(field)`, `map.cvRemove(field)` edit a
  raw map using a field as the key.
* `String.jsonToMap()`, `jsonToMapOrNull()`, `jsonToList()`,
  `jsonToMapList()` decode JSON to model types (`package:cv/cv_json.dart`).
* `jsonPrettyEncode(object)` and `map.cvToJsonPretty()` produce indented JSON.

## Columns

`CvColumn<T>(name)` is a field without a value, useful for describing a schema
or a sort key. `fields.columns` returns the key names of a field list and
`fields.matchingColumns([...])` filters by name.

## Type coercion on read

`fromMap` converts basic types to the field type: `num` to `int` (rounded),
`int` to `double`, and strings to `num`, `bool` or `int` when parseable.
`field.fromBasicTypeValue(value)` applies the same rule to a single field.
`package:cv/utils/type_utils.dart` and `value_utils.dart` expose the helpers
(`isBasicType`, `basicTypeCastType`, `CvColumnTypeExtension.isSubtypeOf<T>()`).

## Test helpers (package:cv/cv_matcher.dart)

```dart
import 'package:cv/cv_matcher.dart';

expect(actualModel, cvEquals(expectedModel));
expect(actualModel, cvEquals({'title': 'x'})); // map or model
var report = cvEqualsDiffReport(actual, expected); // null when equal, else a diff
```

`cvEquals` accepts a `CvModel` or a `Map` on either side and prints a
readable diff on failure.

Filling models with generated data:

* `model.fillModel(cvFillOptions1)` sets every field (recursively) with
  deterministic values (`text_1`, `1`, `true`...). `CvFillOptions` controls
  `valueStart`, `collectionSize` and a custom `generate` callback.
* `field.fillField(options)`, `listField.fillList(options)`,
  `modelField.fillModel(options)` do the same for one field.
* `fillModelMatchesMap(map, options)` is experimental and matches a model type
  against the map its filled instance produces.
