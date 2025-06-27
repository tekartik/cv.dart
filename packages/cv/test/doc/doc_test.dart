// ignore_for_file: omit_local_variable_types, avoid_print

import 'package:cv/cv_json.dart';
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
        'date': DateTime(2021, 08, 16),
      });
    });

    test('fromMap', () {
      var note = Note();
      note.fromMap({
        'title': 'My note',
        'content': 'My note context',
        'date': DateTime(2021, 08, 16),
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

    test('cv child', () {
      // Add the builders once
      cvAddConstructor(Rect.new);
      cvAddConstructor(Point.new);
      cvAddConstructor(Size.new);

      // Any map can be converted to a rect object
      var rect = {
        'point': {'x': 100, 'y': 50},
        'size': {'width': 300, 'height': 200},
      }.cv<Rect>();
      var size = rect.size.v!;
      expect(size.width.v, 300);

      // print(rect.toMap());
      // {point: {x: 100, y: 50}, size: {width: 300, height: 200}}
    });

    test('cv children', () {
      // Add the builders once
      cvAddConstructor(ShoppingCart.new);
      cvAddConstructor(Item.new);

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
    });

    test('json', () {
      // Add the builders once
      cvAddBuilder<ShoppingCart>((_) => ShoppingCart());
      cvAddBuilder<Item>((_) => Item());

      /// Any json
      var cartJson =
          '{"items":[{"name":"Chair","price":50},{"name":"Lamp","price":12}]}';

      /// Create a cart object
      var cart = cartJson.cv<ShoppingCart>();

      print(cart.toJson());
      // {items: [{name: Chair, price: 50}, {name: Lamp, price: 12}]}

      var items = cart.items.v!;
      expect(items[0].name.v, 'Chair');
    });

    test('jsonList', () {
      // Add the builders once
      cvAddBuilder<ShoppingCart>((_) => ShoppingCart());
      cvAddBuilder<Item>((_) => Item());

      var itemsJson =
          '[{"name":"Chair","price":50},{"name":"Lamp","price":12}]';

      /// Create a list of objects
      var items = itemsJson.cvList<Item>();

      print(items.toJson());
      // [{"name":"Chair","price":50},{"name":"Lamp","price":12}]

      expect(items[0].name.v, 'Chair');
    });
  });
}

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
