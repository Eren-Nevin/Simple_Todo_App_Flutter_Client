import 'package:flutter/material.dart';
import 'dart:math';
import './api.dart';
import './model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Item> itemList = [];

  _MyHomePageState() {
    getItemsFromServer().then((value) => {setState(() => itemList = value)});
  }

  newItemHandler() {
    setState(() => {
          itemList = [
            ...itemList,
            Item(Random().nextInt(10000), 'New-Flutter',
                DateTime.now().millisecondsSinceEpoch)
          ]
        });
    sendItemsToServer(itemList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          child: ListView(
            children: itemList.map((item) => ItemWidget(item.title)).toList(),
          ),
          margin: EdgeInsets.all(8.0),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: newItemHandler,
        tooltip: 'Add New Item',
        child: Icon(Icons.add),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  ItemWidget(this.title);
  String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        child: Text(
          '$title',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
        ),
        margin: EdgeInsets.only(left: 16.0, right: 16.0),
      ),
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
    );
  }
}
