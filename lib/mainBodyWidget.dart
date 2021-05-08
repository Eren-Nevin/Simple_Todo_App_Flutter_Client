import 'package:flutter/material.dart';
import 'package:list/itemWidgetList.dart';
import 'package:list/newItemWidget.dart';

import 'viewModel.dart';

class ItemListWithTextFieldWidget extends StatefulWidget {
  final ViewModel _viewModel;

  final ValueNotifier<bool> startAddingItems;

  ItemListWithTextFieldWidget(this._viewModel, this.startAddingItems);

  @override
  State<ItemListWithTextFieldWidget> createState() {
    return _ItemListWithTextFieldState(_viewModel, startAddingItems);
  }
}

class _ItemListWithTextFieldState extends State<ItemListWithTextFieldWidget> {
  ViewModel _viewModel;
  bool addingItemState = false;
  _ItemListWithTextFieldState(
      ViewModel viewModel, ValueNotifier<bool> startAddingItems) {
    _viewModel = viewModel;
    startAddingItems.addListener(() {
      setState(() {
        addingItemState = true;
      });
    });
  }

  onNewItemTextSubmit(String newItemTitle) {
    setState(() {
      addingItemState = false;
      _viewModel.addItem(newItemTitle);
    });
  }

  Future<void> onRefreshHandler() async {
    await _viewModel.syncItems();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Visibility(
          child: NewItemWidget(onNewItemTextSubmit), visible: addingItemState),
      // TODO: Add Animation For Adding Items To List This can be done in
      // a hacky way by Layering An AnimatedListView On Top Of
      // ReorderableListView While An Item Is Being Added Then After
      // Animation Is Ended, Make Reorderable One Active.
      Flexible(
        child: RefreshIndicator(
            child: ItemWidgetList(_viewModel), onRefresh: onRefreshHandler),
      ),
    ]);
  }
}
