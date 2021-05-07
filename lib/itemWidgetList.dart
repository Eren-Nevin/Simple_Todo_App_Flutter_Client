import 'package:flutter/material.dart';

import './viewItem.dart';
import './viewModel.dart';
import './itemWidget.dart';

class ItemWidgetList extends StatefulWidget {
  ViewModel viewModel;
  ItemWidgetList(this.viewModel);
  @override
  State<StatefulWidget> createState() {
    return _ItemWidgetListState(viewModel);
  }
}

class _ItemWidgetListState extends State<ItemWidgetList> {
  List<ViewItem> _itemList = [];
  ViewModel _viewModel;

  _ItemWidgetListState(ViewModel viewModel) {
    _viewModel = viewModel;
    _viewModel.getViewItemListStream().listen((event) {
      setState(() {
        _itemList = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      children: _itemList.map((e) => ItemWidget(e)).toList(),
      onReorder: (oldPos, newPos) {
        var _newList = reorderableListViewOrderer(_itemList, oldPos, newPos);
        _viewModel.setItemsFromViewItems(_newList);
        // setState(() {
        //   _itemList = _newList;
        // });
      },
    );
  }
}

List<T> reorderableListViewOrderer<T>(List<T> oldList, int oldPos, int newPos) {
  var movingItem = oldList.removeAt(oldPos);

  // print("$oldPos, $newPos");

  // TODO: Why this is necessary?
  if (newPos > oldPos) newPos--;

  List<T> _newList = [];

  for (var i = 0; i < oldList.length + 1; i++) {
    if (i < newPos)
      _newList.add(oldList[i]);
    else if (i == newPos) {
      _newList.add(movingItem);
    } else {
      _newList.add(oldList[i - 1]);
    }
  }

  return _newList;
}
