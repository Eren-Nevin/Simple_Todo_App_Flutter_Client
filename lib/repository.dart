import 'dart:async';
import 'dart:convert';
import './model.dart';
import 'package:http/http.dart' as http;

// // This is because on android emulator localhost is accessible as 10.0.2.2

List<Item> deserializeItemList(String rawData) {
  List<dynamic> rawResult = json.decode(rawData);
  List<Item> result = rawResult
      .map((value) => Item(value['id'], value['title'], value['timestamp']))
      .toList();
  return result;
}

abstract class Repository {
  Stream<List<Item>> getItemListStream();
  Future<void> updateItems(List<Item> itemList);
  void start();
}

// This is the stand-in repository that connects to server for each action
// without any caching or smart behavior.
class BasicDartNetworkRepository implements Repository {
  final defaultServerAddress = "http://localhost:9999";
  String _getEndPoint;
  String _sendEndPoint;

  StreamController<List<Item>> _itemListStreamController;
  Stream<List<Item>> _itemListStream;

  BasicDartNetworkRepository({String getEndpoint, String sendEndpoint}) {
    _getEndPoint = getEndpoint ?? "$defaultServerAddress/api/get_items";
    _sendEndPoint = sendEndpoint ?? "$defaultServerAddress/api/send_items";
    _itemListStreamController = StreamController();
    _itemListStream = _itemListStreamController.stream;
  }

  @override
  void start() {
    _fetch();
  }

  _fetch() async {
    var itemList = await _getItemsFromServer();
    _itemListStreamController.add(itemList);
  }

  _getItemsFromServer() async {
    var url = Uri.parse(_getEndPoint);
    var rawString = await http.read(url);
    var result = deserializeItemList(rawString);
    return result;
  }

  _sendItemsToServer(List<Item> itemList) async {
    var url = Uri.parse(_sendEndPoint);
    await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(itemList));
  }

  @override
  Stream<List<Item>> getItemListStream() {
    return _itemListStream;
  }

  @override
  Future<void> updateItems(List<Item> itemList) async {
    await _sendItemsToServer(itemList);
    // Should this be await too?
    _fetch();
    return null;
  }
}

class DartNetworkWithCacheRepository extends BasicDartNetworkRepository {
  StreamController<List<Item>> _cachedItemListStreamController;
  Stream<List<Item>> _cachedItemListStream;

  List<Item> _cachedItemList = [];

  DateTime lastFetchTime;

  DartNetworkWithCacheRepository({String getEndpoint, String sendEndpoint})
      : super(getEndpoint: getEndpoint, sendEndpoint: sendEndpoint) {
    _cachedItemListStreamController = StreamController();
    _cachedItemListStream = _cachedItemListStreamController.stream;
    // Everytime the network stream gets a new itemList from server, it updates
    // the client side itemList stream as well.
    _cachedItemListStream.listen((event) {
      _itemListStreamController.add(event);
      _cachedItemList = event;
      _maybeSync(event);
    });
  }

  @override
  _fetch() async {
    var itemListFromServer = await _getItemsFromServer();
    _cachedItemListStreamController.add(itemListFromServer);
    lastFetchTime = DateTime.now();
  }

  @override
  Future<void> updateItems(List<Item> itemList) async {
    _cachedItemListStreamController.add(itemList);
    return;
  }

  _maybeSync(List<Item> items) async {
    if (DateTime.now().difference(lastFetchTime) > Duration(seconds: 10)) {
      await _sendItemsToServer(items);
      await _fetch();
    }
  }
}

// This would be the real repository connected
class NativeRepository implements Repository {
  StreamController<List<Item>> _itemListStreamController;
  Stream<List<Item>> itemListStream;

  NativeRepository() {
    itemListStream = _itemListStreamController.stream;
  }

  void onDataRecieved(String rawData) {
    List<Item> currentList = deserializeItemList(rawData);
    _itemListStreamController.add(currentList);
  }

  void onClose() {
    _itemListStreamController.close();
  }

  @override
  Stream<List<Item>> getItemListStream() {
    return itemListStream;
  }

//TODO: Implement Update Items.
  @override
  Future<void> updateItems(List<Item> itemList) {
    return null;
  }

  @override
  void start() {
    // TODO: implement start
  }
}
