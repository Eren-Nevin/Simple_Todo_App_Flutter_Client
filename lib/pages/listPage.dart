import 'package:flutter/material.dart';
import 'package:list/itemWidgetList.dart';
import 'package:list/newItemWidget.dart';

import 'package:list/viewModel.dart';
import 'package:list/utilities.dart';

class ListPage extends StatefulWidget {
  final String title;
  final Map<String, dynamic> credentials;
  final VoidCallback onLogout;
  ListPage(this.credentials, this.onLogout, {Key key, this.title})
      : super(key: key);

  @override
  _ListPageState createState() => _ListPageState(credentials, onLogout);
}

class _ListPageState extends State<ListPage> {
  ListViewModel _viewModel;
  VoidCallback onLogout;
  ValueNotifier<bool> addingNewItem = ValueNotifier(false);
  Key itemWidgetListGlobalKey = GlobalKey();
  Key otherKey = GlobalKey();
  Key newItemWidgetKey = GlobalKey();

  _ListPageState(Map<String, dynamic> credentials, this.onLogout) {
    _viewModel = ListViewModel(credentials);
  }

  // TODO: Make a proper destructor.
  cleanUpAndLogout() {
    _viewModel.destructor();
    _viewModel = null;
    onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBuilder(
          "${getWeekDayName(DateTime.now())}", "Groceries", cleanUpAndLogout),
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          child: Column(children: [
            NewItemWidget(
              (str) {
                _viewModel.addNewItem(str, "Details");
              },
              addingNewItem,
              key: newItemWidgetKey,
            ),
            Flexible(
              child: ItemWidgetList(_viewModel, key: itemWidgetListGlobalKey),
            ),
          ]),
          margin: EdgeInsets.all(8.0),
        ),
        color: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addingNewItem.value = true;
        },
        tooltip: 'Add New Item',
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget appBarBuilder(String title, String subtitle, VoidCallback onLogout) {
  return AppBar(
      title: AppBarTitle(title, subtitle),
      titleSpacing: 24.0,
      centerTitle: false,
      elevation: 0,
      actions: [
        IconButton(icon: Icon(Icons.share), onPressed: () {}),
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: "Logout",
              child: Text("Logout"),
            ),
          ],
          onSelected: (value) {
            print("$value is selected");
            switch (value) {
              case "Logout":
                onLogout();
                break;
              default:
                throw Error();
            }
          },
        ),
      ],
      backgroundColor: Colors.indigo);
}

class AppBarTitle extends StatelessWidget {
  final String title, subtitle;
  // TextTheme textTheme;
  AppBarTitle(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    // textTheme = Theme.of(context).appBarTheme
    return Column(
      children: [
        Align(
            child: Text(title, style: TextStyle(fontSize: 24.0)),
            alignment: Alignment.topLeft),
        Align(
            child: Text(subtitle, style: TextStyle(fontSize: 16.0)),
            alignment: Alignment.topLeft),
      ],
    );
  }
}

//TODO: Have One Tab in Navigation Bar For Private List, The Other Two Can Be
//Groceries & Family Tasks Which Are Shared Among A Family.

Widget bottomNavigationBarBuilder() {
  return BottomNavigationBar(
    items: [
      BottomNavigationBarItem(
          label: "Groceries",
          icon: Icon(Icons.shopping_bag_rounded,
              size: 36.0, color: Colors.green.shade200)),
      BottomNavigationBarItem(
          label: "Groceries",
          icon: Icon(Icons.shopping_bag_rounded,
              size: 36.0, color: Colors.green.shade600)),
      BottomNavigationBarItem(
          label: "Groceries",
          icon: Icon(Icons.shopping_bag_rounded,
              size: 36.0, color: Colors.green.shade600)),
    ],
    backgroundColor: Colors.purple.shade900,
    showUnselectedLabels: false,
    showSelectedLabels: false,
  );
}
