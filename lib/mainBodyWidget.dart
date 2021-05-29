import 'package:flutter/material.dart';

import 'viewModel.dart';

class ItemListWithTextFieldWidget extends StatefulWidget {
  final ViewModel _viewModel;

  ItemListWithTextFieldWidget(this._viewModel, {Key key}) : super(key: key);

  @override
  State<ItemListWithTextFieldWidget> createState() {
    return _ItemListWithTextFieldState(_viewModel);
  }
}

class _ItemListWithTextFieldState extends State<ItemListWithTextFieldWidget> {
  ViewModel _viewModel;
  final ValueNotifier<bool> startAddingItems = ValueNotifier(false);
  bool addingItemState = false;
  _ItemListWithTextFieldState(ViewModel viewModel) {
    _viewModel = viewModel;
    startAddingItems.addListener(() {
      setState(() {
        addingItemState = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {}
}
