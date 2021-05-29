import 'dart:async';
import 'package:flutter/material.dart';

import './viewModel.dart';
import './model.dart';
import './itemWidget.dart';

class ItemWidgetList extends StatefulWidget {
  ViewModel _viewModel;
  ItemWidgetList(this._viewModel, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemWidgetListState(_viewModel);
  }
}

class _ItemWidgetListState extends State<ItemWidgetList> {
  ViewModel _viewModel;
  // AnimatedListState animatedListState;
  GlobalKey<AnimatedListState> listKey;
  List<Item> _itemList = [];

  _ItemWidgetListState(this._viewModel) {
    listKey = GlobalKey<AnimatedListState>();
    _itemList = [..._viewModel.getCurrentItems()];

    // _viewModel.getItemListStream().listen((newList) {
    //   List<Item> previousItemList = [..._itemList];
    //   _itemList = [...newList];
    //   if (previousItemList.length == 0) {
    //     for (int i = 0; i < _itemList.length; i++) {
    //       listKey.currentState.insertItem(i);
    //     }
    //   }
    // });

    _viewModel.getItemAddedStream().listen((item) {
      print("Item ${item.title} is being added");
      _itemList.insert(0, item);
      print("""ListWidget ItemList is ${_itemList.map((e) => e.title)}
              """);
      // _itemList.insert(0, item);
      listKey.currentState.insertItem(0);
      // _viewModel.addItem(item);
    });

    _viewModel.getItemRemovedStream().listen((item) {
      print("Item ${item.title} is being removed");
      print(
          "Before Removing the Item List is ${_itemList.map((e) => e.title)}");
      int index = _itemList.indexWhere((element) => element.id == item.id);

      _itemList.removeAt(index);
      listKey.currentState.removeItem(index, (context, animation) {
        animation.addStatusListener((status) {
          print(status);
          // _viewModel.removeItem(item);
        });
        return SizedBox(
          height: 0,
          width: 0,
        );
      });
    });

    _viewModel.getItemChangedStream().listen((item) {
      print("Item ${item.title} is being changed");
      // print("Widget List Listened On ${item.title} Change");
      int index = _itemList.indexWhere((element) => element.id == item.id);
      // print("Index Is $index");
      _itemList[index] = item;
    });
  }

  // static List<int> calculatePreviousIds(List<Item> previousItemList) {
  //   return previousItemList.map((e) => e.id).toList();
  // }

  @override
  Widget build(BuildContext context) {
    print("Building ItemWidgetList");
    Widget animatedList = AnimatedList(
      key: listKey,
      itemBuilder: (context, index, animation) {
        // print("${_itemList.map((e) => e.item.title).toList()} From Builder");
        print("Index Is: $index");
        print("Building $index which is ${_itemList[index].title}");
        if (index >= _itemList.length) {
          return null;
        } else {
          //TODO: Make Animation Instant When Fetching Multiple Data.
          print("Creating Item ${_itemList[index].title}");
          final int itemId = _itemList[index].id;
          return SlideTransition(
            position: animation
                .drive(Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero)),
            child: ItemWidget(_viewModel, itemId, key: ValueKey(itemId)),
          );
        }
      },
      initialItemCount: 0,
    );
    return animatedList;
  }
}

// class ItemWidgetList extends StatefulWidget {
//   ViewModel viewModel;
//   ItemWidgetList(this.viewModel);
//   @override
//   State<StatefulWidget> createState() {
//     return _ItemWidgetListState(viewModel);
//   }
// }

// class _ItemWidgetListState extends State<ItemWidgetList> {
//   List<Item> _itemList = [];
//   ViewModel _viewModel;

//   _ItemWidgetListState(ViewModel viewModel) {
//     _viewModel = viewModel;
//     _viewModel.getItemListStream().listen((event) {
//       setState(() {
//         _itemList = event;
//       });
//     });
//   }
//   Widget animatedListItemBuilder(
//       BuildContext context, int index, Animation<double> animation) {
//     print("Called $index");
//     return ItemWidget(_itemList[index]);
//     // return Text("$index");
//   }

//   @override
//   Widget build(BuildContext context) {
//     // return reorderableListViewBuilder(_itemList, _viewModel);
//     return ListView(
//       children: _itemList.map((e) => ItemWidget(e)).toList(),
//     );
//     // return animatedListViewBuilder(_itemList);
//   }
// }

// Widget animatedListViewBuilder(List<Item> itemList) {

//   print("Coooled");

// }

// Widget reorderableListViewBuilder(
//     List<Item> itemList, ViewModel viewModel) {
//   return ReorderableListView(
//     children: itemList.map((e) => ItemWidget(e)).toList(),
//     onReorder: (oldPos, newPos) {
//       var _newList = reorderableListViewOrderer(itemList, oldPos, newPos);

//       // We do this to make sure item order is the same as their index in the list.
//       for (var i = 0; i < _newList.length; i++) {
//         if (_newList[i].item.theOrder != i) {
//           _newList[i].item.theOrder = i;
//           _newList[i].item.timestamp = DateTime.now().millisecondsSinceEpoch;
//         }
//       }

//       viewModel.setItemsFromItems(_newList);
//     },
//   );
// }

// List<T> reorderableListViewOrderer<T>(List<T> oldList, int oldPos, int newPos) {
//   var movingItem = oldList.removeAt(oldPos);

//   // print("$oldPos, $newPos");

//   // TODO: Why is this necessary?
//   if (newPos > oldPos) newPos--;

//   List<T> _newList = [];

//   for (var i = 0; i < oldList.length + 1; i++) {
//     if (i < newPos)
//       _newList.add(oldList[i]);
//     else if (i == newPos) {
//       _newList.add(movingItem);
//     } else {
//       _newList.add(oldList[i - 1]);
//     }
//   }

//   return _newList;
// }
