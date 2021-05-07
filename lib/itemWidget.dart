import 'package:flutter/material.dart';
import './viewItem.dart';

class ItemWidget extends StatelessWidget {
  String _itemTitle;
  void Function() _itemClickHandler;
  // We take all objects necessary for constructing an ItemWidget in its
  // constructor

  ItemWidget(ViewItem viewItem) {
    _itemTitle = viewItem.item.title;
    _itemClickHandler = viewItem.tapHandler;
  }

  @override
  final key = UniqueKey();

  // For now we use a ListTile widget as our base.
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DecoratedBox(
        child: ListTile(
          title: Text(_itemTitle, style: TextStyle(fontSize: 24.0)),
          onTap: _itemClickHandler,
        ),
        decoration: itemDecoration,
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}

ShapeDecoration itemDecoration = ShapeDecoration(
  shape: RoundedRectangleBorder(
      side: BorderSide(), borderRadius: BorderRadius.all(Radius.circular(8.0))),
  color: Colors.cyan,
);
