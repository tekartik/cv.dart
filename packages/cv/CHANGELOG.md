## 0.2.15

* add `CvFields` type as `List<CvField<Object?>>`

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
