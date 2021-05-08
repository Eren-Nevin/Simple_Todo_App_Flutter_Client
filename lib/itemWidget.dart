import 'package:flutter/material.dart';
import './viewItem.dart';

class ItemWidget extends StatelessWidget {
  String _itemTitle;
  void Function() _itemRemoveHandler;
  // We take all objects necessary for constructing an ItemWidget in its
  // constructor

  ItemWidget(ViewItem viewItem) {
    _itemTitle = viewItem.item.title;
    _itemRemoveHandler = viewItem.removeHandler;
  }

  @override
  final key = UniqueKey();

  // For now we use a ListTile widget as our base.
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key,
      child: Container(
        child: ListTile(
          title: Text(_itemTitle, style: TextStyle(fontSize: 20.0)),
          subtitle: Text(
            "subtitle",
          ),
          leading: Icon(
            Icons.star_outline_rounded,
            size: 32.0,
          ),
          // tileColor: Colors.white,
        ),
        margin: EdgeInsets.symmetric(vertical: 1.0),
        decoration: itemDecoration,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // TODO: Show TimePicker For Reminders.
          return false;
        } else {
          return true;
        }
      },
      onDismissed: (direction) {
        _itemRemoveHandler();
      },
      // onResize: () {
      //   print("Resizing");
      // },
      // TODO: Add Animation To Background
      direction: DismissDirection.horizontal,
      background: Container(
          child: Container(
            child: Icon(Icons.delete_sharp, size: 32.0, color: Colors.white),
            margin: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          alignment: Alignment.centerLeft,
          decoration: removeDismissDecoration),
      // secondaryBackground: Container(color: Colors.green),
    );
  }
}

ShapeBorder listItemShapeBorder = RoundedRectangleBorder(
    side: BorderSide(style: BorderStyle.none),
    borderRadius: BorderRadius.circular(6.0));

ShapeDecoration itemDecoration = ShapeDecoration(
  shape: listItemShapeBorder,
  color: Colors.white,
);

ShapeDecoration removeDismissDecoration =
    ShapeDecoration(shape: listItemShapeBorder, color: Colors.red);
