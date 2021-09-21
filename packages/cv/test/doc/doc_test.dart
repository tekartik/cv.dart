import 'package:cv/cv.dart';
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
        'date': DateTime(2021, 08, 16)
      });
    });

    test('fromMap', () {
      var note = Note();
      note.fromMap({
        'title': 'My note',
        'content': 'My note context',
        'date': DateTime(2021, 08, 16)
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
      cvAddBuilder<Rect>((_) => Rect());
      cvAddBuilder<Point>((_) => Point());
      cvAddBuilder<Size>((_) => Size());

      // Any map can be converted to a rect object
      var rect = {
        'point': {'x': 100, 'y': 50},
        'size': {'width': 300, 'height': 200}
      }.cv<Rect>();
      var size = rect.size.v!;
      expect(size.width.v, 300);

      // print(rect.toMap());
      // {point: {x: 100, y: 50}, size: {width: 300, height: 200}}
    });

    test('cv children', () {
      // Add the builders once
      cvAddBuilder<ShoppingCart>((_) => ShoppingCart());
      cvAddBuilder<Item>((_) => Item());

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
    });
  });
}

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
