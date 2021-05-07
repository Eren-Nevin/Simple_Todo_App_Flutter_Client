import 'dart:async';

import 'package:flutter/material.dart';

import './model.dart' show Item;
import './viewItem.dart' show ViewItem;
import './repository.dart';

class ViewModel {
  Repository _repository;
  List<Item> lastItemList;
  Stream<List<Item>> _itemListStream;
  StreamController<List<ViewItem>> _viewItemListStreamController;
  Stream<List<ViewItem>> _viewItemListStream;

  ViewModel({Repository repository}) {
    _repository = repository ?? DartNetworkWithCacheRepository();
    _itemListStream = _repository.getItemListStream();
    _viewItemListStreamController = StreamController();
    _viewItemListStream = _viewItemListStreamController.stream;
    _repository.start();
    startListeningOnItemListStream();
  }

  void startListeningOnItemListStream() {
    _itemListStream.listen((event) {
      lastItemList = event;
      List<ViewItem> viewItemList =
          event.map((e) => getViewItem(this, e)).toList();
      _viewItemListStreamController.add(viewItemList);
    });
  }

  Stream<List<ViewItem>> getViewItemListStream() {
    return _viewItemListStream;
  }

  Future<void> _sendItems(List<Item> itemList) async {
    await _repository.updateItems(itemList);
  }

  Future<void> removeItem(Item item) async {
    lastItemList.remove(item);
    await _sendItems(lastItemList);
  }

  Future<void> setItems(List<Item> itemList) async {
    await _sendItems(itemList);
  }

  Future<void> setItemsFromViewItems(List<ViewItem> viewItems) async {
    await _sendItems(getItemListFromViewItemList(viewItems));
  }

  //TODO: Add Item

  // TODO: Make TapHandler Send Items
}

ViewItem getViewItem(ViewModel viewModel, Item item) {
  tapHandler() {
    viewModel.removeItem(item);
  }

  return ViewItem(item, tapHandler);
}

List<Item> getItemListFromViewItemList(List<ViewItem> viewItems) {
  return viewItems.map((e) => e.item).toList();
}
