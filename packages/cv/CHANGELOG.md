## 1.1.0

* add `keyPartsToString` and `keyPartsFromString`
* add helper `CvModel.valueAtPath(path)` to get a model value at a given path.
* Fixe clone issue with subclasses dispatch.

## 1.0.0+1

* Make it `1.0.0`
* requires dart `3.4.0`
* add default `CvMapModel` builder
* Fix basic list item safe conversion

## 0.2.20+1

* Add `Map.deepClone`, `List.deepClone` and `Object.anyDeepClone`.
 
## 0.2.19+1

* add `CvTreePath` field tree path helper.
* add `basicTypeCast, basicTypeCastType` utils in `utils/value_utils.dart`.
* round double read as int instead of truncate.

## 0.2.18+1

* add `cvAddConstructors()` and `cvTypeAddBuilder()`
* add `anyAs` on Object to safely convert an object to any type
* add `asModel` on Map to cast a map to a model
* add `asModelList` on List to cast a list to a model list
* add `clone` to `CvModel` to clone a model

## 0.2.17+2

* add `cvType()` extensions
* add `cvNewModel()`, `cvTypeNewModel()`, `cvNewModelList()`, `cvTypeNewModelList()` helper
* add `fieldAtPath()` helper on `CvModel`
* add `getKeyPathValue()` helper on `List` and `Map`

## 0.2.16+2

* add `columns` argument in `CvModel.copyFrom()`
* add `matchingColumns()`, `columns` helper on `CvFields`

## 0.2.15

* add `CvFields` type as `List<CvField<Object?>>`.

## 0.2.14

* add `CvModelEmpty` to be used as empty model

## 0.2.13

* add `CvField.encoded` static function to encode a field content during `toMap()`/`fromMap()`
* add `cvModelsAreEquals` helpers with optional columns selection to compare 2 models

## 0.2.12+1

* export `CvColumn`
* fix fill option for Model like for Map

## 0.2.11

* Dart 3 support

## 0.2.10

* fix sdk 2.19 analyzer crash

## 0.2.9+3

* Supports strict-casts
* requires sdk 2.18

## 0.2.8+1

- lazy initialize model list object in cvList.

## 0.2.7

- add support for map of CvModel (CvModelMapField)

## 0.2.6

- add jsonToMap and jsonToMapList json String helpers

## 0.2.5

- Requires dart 2.15

## 0.2.4+1

- feat add json helpers

## 0.2.3+1

- Allow nullable for `CvField.withValue`, value being always set, even for null.
- Fix `fillField` for generic `List` and `Map`

## 0.2.2

- Add `CvField.isNotNull`, `CvField.valueOrNull` (getter and setter) and `CvField.valueOrThrow` (getter and setter)

## 0.2.1+1

- Add cv() as extension on List<Map>.

## 0.2.0

- Fail when child/children builder are missing

## 0.1.3

- Initial version.
