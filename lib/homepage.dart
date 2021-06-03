import 'package:flutter/material.dart';
// import 'package:list/mainBodyWidget.dart';
import 'package:list/itemWidgetList.dart';
import 'package:list/newItemWidget.dart';

import './viewModel.dart';
import 'utilities.dart';

class MyHomePage extends StatefulWidget {
  final ViewModel _viewModel;
  MyHomePage(this._viewModel, {Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState(_viewModel);
}

class _MyHomePageState extends State<MyHomePage> {
  ViewModel _viewModel;
  ValueNotifier<bool> addingNewItem = ValueNotifier(false);
  Key itemWidgetListGlobalKey = GlobalKey();
  Key otherKey = GlobalKey();
  Key newItemWidgetKey = GlobalKey();
  // bool isConnected = false;

  _MyHomePageState(this._viewModel) {
    _viewModel.dataReset.addListener(() {
      // setState(() {
      // isConnected = _viewModel.dataReset.value;
      // });
    });
  }

  //TODO: Remove This and the refresh handler itself.
  Future<void> onRefreshHandler() async {
    // _viewModel.starAllItems();
    // Future.delayed(Duration(seconds: 3), () {
    //   _viewModel.addNewItem("Testing", "details");
    // });
    // await _viewModel.syncWithServer();
    // return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBuilder("${getWeekDayName(DateTime.now())}", "Groceries"),
      body: Stack(
        children: [
          Container(
            alignment: Alignment.topCenter,
            child: Container(
              child: Column(children: [
                NewItemWidget(
                  (str) {
                    // _viewModel.addItem(str, "Details");
                    _viewModel.addNewItem(str, "Details");
                  },
                  addingNewItem,
                  key: newItemWidgetKey,
                ),
                Flexible(
                  child: RefreshIndicator(
                      key: otherKey,
                      child: ItemWidgetList(_viewModel,
                          key: itemWidgetListGlobalKey),
                      onRefresh: onRefreshHandler),
                ),
              ]),
              // child: ItemListWithTextFieldWidget(_viewModel, startAddingItems),
              margin: EdgeInsets.all(8.0),
            ),
            color: Colors.indigo,
          ),
          // Visibility(
          //     child: Icon(Icons.question_answer_sharp, size: 200),
          //     visible: !isConnected),
        ],
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
// onNewItemTextSubmit(String newItemTitle) {
//     setState(() {
//       addingItemState = false;
//       // TODO: Add Ability To Change Details
//       _viewModel.addItem(newItemTitle, "Details");
//     });
//   }

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

Widget appBarBuilder(String title, String subtitle) {
  return AppBar(
      title: AppBarTitle(title, subtitle),
      titleSpacing: 24.0,
      centerTitle: false,
      elevation: 0,
      actions: [
        IconButton(icon: Icon(Icons.share), onPressed: () {}),
        PopupMenuButton(
            itemBuilder: (context) => [
                  PopupMenuItem(child: Text("Hello")),
                  PopupMenuItem(child: Text("World")),
                ]),
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
