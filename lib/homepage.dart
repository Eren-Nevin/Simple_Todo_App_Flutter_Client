import 'package:flutter/material.dart';

import 'dart:math';
// import './model.dart';
import './viewModel.dart';
import './itemWidgetList.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ViewModel _viewModel;
  _MyHomePageState() {
    _viewModel = ViewModel();
  }
  // List<Item> itemList = [];

  // _MyHomePageState() {
  //   _getItemsFromServer().then((value) => {setState(() => itemList = value)});
  // }

  // newItemHandler() {
  //   setState(() => {
  //         itemList = [
  //           ...itemList,
  //           Item(Random().nextInt(10000), 'New-Flutter',
  //               DateTime.now().millisecondsSinceEpoch)
  //         ]
  //       });
  //   _sendItemsToServer(itemList);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(8.0),
        child: ItemWidgetList(_viewModel),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Add New Item',
        child: Icon(Icons.add),
      ),
    );
  }
}
