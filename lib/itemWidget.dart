import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import './model.dart';
import './viewModel.dart';

class ItemWidget extends StatefulWidget {
  ViewModel _viewModel;

  int _itemId;

  ItemWidget(this._viewModel, this._itemId, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemWidgetState(_viewModel, _itemId);
  }
}

class _ItemWidgetState extends State<StatefulWidget> {
  int _itemId;
  Item _item;
  ViewModel _viewModel;
  StreamSubscription sub;
  _ItemWidgetState(this._viewModel, this._itemId) {
    sub = _viewModel.getItemChangedStream().listen((event) {
      // print("Item State Changed");
      setState(() {});
    });
  }

  @override
  void dispose() {
    sub.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _item = _viewModel.getItemForId(_itemId);
    // print("Rebuilding ${_item.title}");
    // print("${_item.important}");
    return Dismissible(
      key: ValueKey("${_item.id} Dismissible"),
      child: Container(
        child: listTileBuilder(_item.title, _item.details, _item.important,
            () async {
          print("Star Clicked On ${_item.title}");
          _viewModel.toggleStarItem(_item);
          // await _streamSub.cancel();
          // _changedItemsStream = null;
        }),
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
      onDismissed: (direction) async {
        print("Dismissing ${_item.title}");
        // await _streamSub.cancel();
        _viewModel.removeItem(_item);
      },
      onResize: () {},
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

Widget listTileBuilder(String _itemTitle, String _itemDetails,
    bool _itemImportance, VoidCallback _starHandler) {
  return ListTile(
    title: Text(_itemTitle, style: TextStyle(fontSize: 20.0)),
    subtitle: _itemDetails.isEmpty ? null : Text(_itemDetails),
    // leading: TweenAnimationBuilder(
    leading: IconButton(
      icon: Icon(
        _itemImportance ? Icons.star_rounded : Icons.star_outline_rounded,
        size: 36.0,
      ),
      onPressed: () {
        _starHandler();
      },
    ),
    // duration: Duration(seconds: 1),
    // tween: Tween(begin: 0.5, end: 1.5),
    // builder: (context, value, child) {
    //   return Transform.scale(child: child, scale: value);
    // },
    // ),
    // minLeadingWidth: 24,
  );
}

ShapeBorder listItemShapeBorder = RoundedRectangleBorder(
    side: BorderSide(style: BorderStyle.none),
    borderRadius: BorderRadius.circular(6.0));

ShapeDecoration itemDecoration = ShapeDecoration(
  shape: listItemShapeBorder,
  color: Colors.white,
  // shadows: [
  //   BoxShadow(
  //       color: Colors.grey.withOpacity(0.5),
  //       spreadRadius: 5,
  //       blurRadius: 8,
  //       offset: Offset.fromDirection(pi / 2, 2))
  // ],
);

ShapeDecoration removeDismissDecoration =
    ShapeDecoration(shape: listItemShapeBorder, color: Colors.red);
