import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import './model.dart' show Item;
import './repository.dart';

class ListViewModel {
  Repository _repository;
  List<Item> _currentItemList = [];
  Stream<Item> _itemAddedStream;
  StreamController<Item> _itemAddedStreamController;
  Stream<Item> _itemRemovedStream;
  StreamController<Item> _itemRemovedStreamController;
  Stream<Item> _itemChangedStream;
  StreamController<Item> _itemChangedStreamController;

  final Map<String, dynamic> credentials;

  StreamSubscription repositoryItemAddedSubscription;
  StreamSubscription repositoryItemChangedSubscription;
  StreamSubscription repositoryItemRemovedSubscription;

  //TODO: Use Getter
  ValueNotifier<bool> dataReset;

  ListViewModel(this.credentials, {Repository repository}) {
    _repository = repository ?? WebsocketNetworkRepository();
    _itemAddedStreamController = StreamController.broadcast();
    _itemAddedStream = _itemAddedStreamController.stream;
    _itemChangedStreamController = StreamController.broadcast();
    _itemChangedStream = _itemChangedStreamController.stream;
    _itemRemovedStreamController = StreamController.broadcast();
    _itemRemovedStream = _itemRemovedStreamController.stream;
    // dataReset = _repository.dataReset;
    _startListeningOnRepository();
    // dataReset.addListener(() {
    // resetItems();
    // });
    connect(credentials);
  }

  void destructor() {
    disconnect();
    _stopListeningOnRepository();
    _repository = null;
  }

  void _startListeningOnRepository() {
    repositoryItemAddedSubscription =
        _repository.getItemAddedStream().listen((item) {
      _currentItemList.insert(0, item);
      _itemAddedStreamController.add(item);
    });
    repositoryItemChangedSubscription =
        _repository.getItemChangedStream().listen((item) {
      int index =
          _currentItemList.indexWhere((element) => element.id == item.id);
      _currentItemList[index] = item;
      _itemChangedStreamController.add(item);
    });
    repositoryItemRemovedSubscription =
        _repository.getItemRemovedStream().listen((item) {
      print("Removing ${item.title} In ViewModel");
      _currentItemList.remove(item);
      _itemRemovedStreamController.add(item);
    });
  }

  _stopListeningOnRepository() {
    repositoryItemAddedSubscription.cancel();
    repositoryItemRemovedSubscription.cancel();
    repositoryItemChangedSubscription.cancel();
  }

  // It needs a dictionary object which has a key called 'token' with a string
  // value.
  // TODO: Change this to an actual type instead of a map.
  connect(Map<String, dynamic> credentials) async {
    _repository.connect(credentials);
  }

  // TODO: Should this be private?
  disconnect() {
    _repository.disconnect();
  }

  resetItems() async {
    for (var item in _currentItemList) {
      _itemRemovedStreamController.add(item);
    }
    _currentItemList = [];
  }

  // TESTING
  Future<void> starAllItems() async {
    for (var item in _currentItemList) {
      item.important = true;
      item.timestamp = DateTime.now().millisecondsSinceEpoch;
      await changeItem(item);
    }
  }

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
  }

  Future<void> addItem(Item item) async {
    print("Adding ${item.title} to ${_currentItemList.map((e) => e.title)}");
    await _repository.addItem(item);
  }

  Future<void> addNewItem(String itemTitle, String details) {
    Item newItem = _createNewItem(itemTitle, details, false);
    addItem(newItem);
  }

  Future<void> changeItem(Item item) async {
    print("Changing ${item.title} in ${_currentItemList.map((e) => e.title)}");
    await _repository.changeItem(item);
  }

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
}

Item _createNewItem(String itemTitle, String subtitle, bool important) {
  return Item(DateTime.now().millisecondsSinceEpoch, Random().nextInt(99999),
      itemTitle, subtitle, DateTime.now().millisecondsSinceEpoch, important);
}
