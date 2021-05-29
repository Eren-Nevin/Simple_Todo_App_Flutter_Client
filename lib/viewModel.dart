import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import './model.dart' show Item;
import './repository.dart';

class ViewModel {
  Repository _repository;
  List<Item> _currentItemList = [];
  Stream<List<Item>> _itemListStream;
  StreamController<List<Item>> _viewItemListStreamController;
  Stream<List<Item>> _viewItemListStream;
  Stream<Item> _itemAddedStream;
  StreamController<Item> _itemAddedStreamController;
  Stream<Item> _itemRemovedStream;
  StreamController<Item> _itemRemovedStreamController;
  Stream<Item> _itemChangedStream;
  StreamController<Item> _itemChangedStreamController;

  ViewModel({Repository repository}) {
    _repository = repository ?? BasicDartNetworkRepository();
    // _itemListStream = _repository.getItemListStream();
    _viewItemListStreamController = StreamController.broadcast();
    _viewItemListStream = _viewItemListStreamController.stream;
    _itemAddedStreamController = StreamController.broadcast();
    _itemAddedStream = _itemAddedStreamController.stream;
    _itemChangedStreamController = StreamController.broadcast();
    _itemChangedStream = _itemChangedStreamController.stream;
    _itemRemovedStreamController = StreamController.broadcast();
    _itemRemovedStream = _itemRemovedStreamController.stream;
    _startListeningOnRepository();
    _repository.start();
  }

  // Stream<List<Item>> getItemListStream() {
  //   return _viewItemListStream;
  // }
  // TESTING
  Future<void> starAllItems() async {
    for (var item in _currentItemList) {
      item.important = true;
      item.timestamp = DateTime.now().millisecondsSinceEpoch;
      await changeItem(item);
    }
  }

  Future<void> syncWithServer() async {
    await _repository.syncWithServer();
  }

  Future<void> syncFromServer() async {
    await _repository.fetch();
  }

  Future<void> syncToServer() async {}

  List<Item> getCurrentItems() {
    return _currentItemList;
  }

  Stream<Item> getItemAddedStream() {
    return _itemAddedStream;
  }

  Stream<Item> getItemRemovedStream() {
    return _itemRemovedStream;
  }

  Stream<Item> getItemChangedStream() {
    return _itemChangedStream;
  }

  Future<void> removeItem(Item item) async {
    print(
        "Removing ${item.title} From ${_currentItemList.map((e) => e.title)}");
    await _repository.removeItem(item);
    // await _repository.syncItems(lastItemList);
  }

  Future<void> addItem(Item item) async {
    print("Adding ${item.title} to ${_currentItemList.map((e) => e.title)}");
    await _repository.addItem(item);
    // Item newItem =
    //     _createNewItem(lastItemList.length, itemTitle, subtitle, false);
    // await _repository.syncItems(lastItemList);
  }

  Future<void> addNewItem(String itemTitle, String details) {
    Item newItem = _createNewItem(itemTitle, details, false);
    addItem(newItem);
  }

  Future<void> changeItem(Item item) async {
    print("Changing ${item.title} in ${_currentItemList.map((e) => e.title)}");
    await _repository.changeItem(item);
  }

  // void removeItemOffered(Item item) {
  //   print("Remove Offer ${item.title}");
  //   _itemChangedStreamController.add(item);
  // }

  // void addItemOffered(String itemTitle, String details) {
  //   Item newItem = _createNewItem(itemTitle, details, false);
  //   _itemAddedStreamController.add(newItem);
  // }

  Future<void> toggleStarItem(Item item) async {
    final int index =
        _currentItemList.indexWhere((element) => element.id == item.id);
    item.important = !_currentItemList[index].important;
    item.timestamp = DateTime.now().millisecondsSinceEpoch;
    changeItem(item);
  }

  Item getItemForId(int itemId) {
    final int index =
        _currentItemList.indexWhere((element) => element.id == itemId);
    return _currentItemList[index];
  }

  // Future<void> setItems(List<Item> itemList) async {
  //   await _repository.syncItems(_currentItemList);
  // }

  // Future<void> setItemsFromItems(List<Item> viewItems) async {
  //   await _repository.syncItems(lastItemList);
  //   await _sendItems(_getItemListFromItemList(viewItems));
  // }

  void _startListeningOnRepository() {
    _repository.getItemAddedStream().listen((item) {
      _currentItemList.insert(0, item);
      print("View Model Listened On New Item Added");
      _itemAddedStreamController.add(item);
      // _itemAddedStreamController.add(event);
    });
    _repository.getItemChangedStream().listen((item) {
      int index =
          _currentItemList.indexWhere((element) => element.id == item.id);
      _currentItemList[index] = item;
      _itemChangedStreamController.add(item);
      // _itemChangedStreamController.add(item);
    });
    _repository.getItemRemovedStream().listen((item) {
      _currentItemList.remove(item);
      _itemRemovedStreamController.add(item);
      // _itemRemovedStreamController.add(item);
    });
  }
}

Item _createNewItem(String itemTitle, String subtitle, bool important) {
  return Item(DateTime.now().millisecondsSinceEpoch, Random().nextInt(99999),
      itemTitle, subtitle, DateTime.now().millisecondsSinceEpoch, important);
}
