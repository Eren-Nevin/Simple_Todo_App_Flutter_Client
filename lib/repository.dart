import 'dart:async';
import 'dart:convert';
import './utilities.dart';
import './model.dart';
import 'package:http/http.dart' as http;

// TODO: Make This Work With All Attributes Got From Server Without Needing To Provide
// Them One By One To Item Serializer
List<Item> deserializeItemList(String rawData) {
  List<dynamic> rawResult = json.decode(rawData);
  List<Item> result = rawResult
      .map((rawTransaction) => Item(
          rawTransaction['id'],
          rawTransaction['the_order'],
          rawTransaction['title'],
          rawTransaction['details'],
          rawTransaction['timestamp'],
          rawTransaction['important']))
      .toList();
  return result;
}

List<Transaction> deserializeTransactions(String rawData) {
  List<dynamic> rawResult = json.decode(rawData);
  List<Transaction> result = rawResult
      .map((rawTransaction) => rawTransactionConvertor(rawTransaction))
      .toList();
  return result;
}

Transaction rawTransactionConvertor(dynamic rawTransaction) {
  Transaction result = Transaction();
  switch (rawTransaction['transaction_type']) {
    case 'Add':
      result.type = TransactionType.Add;
      break;
    case 'Modify':
      result.type = TransactionType.Modify;
      break;
    case 'Remove':
      result.type = TransactionType.Remove;
      break;
  }
  result.id = rawTransaction['transaction_id'];
  result.item = Item(
      rawTransaction['item_id'],
      rawTransaction['arb_order'],
      rawTransaction['title'],
      rawTransaction['details'],
      rawTransaction['timestamp'],
      rawTransaction['important']);
  return result;
}

abstract class Repository {
  Stream<Item> getItemAddedStream();
  Stream<Item> getItemRemovedStream();
  Stream<Item> getItemChangedStream();

  Future<void> addItem(Item item);
  Future<void> changeItem(Item item);
  Future<void> removeItem(Item item);

  // Future<void> syncItems(List<Item> itemList);
  Future<void> syncWithServer();
  Future<void> syncToServer();
  Future<void> fetch();
  // Future<void> syncItems();
  void start();
}

// This is the stand-in repository that connects to server for each action
// without any caching or smart behavior.
class BasicDartNetworkRepository implements Repository {
  Stream<Item> _itemAddedStream;
  Stream<Item> _itemChangedStream;
  Stream<Item> _itemRemovedStream;

  StreamController<Item> _itemAddedStreamController;
  StreamController<Item> _itemChangedStreamController;
  StreamController<Item> _itemRemovedStreamController;

  final defaultServerAddress = "http://localhost:9999";
  String _getEndPoint;
  // String _getTransactionsEndPoint;
  String _sendEndPoint;
  int lastReceivedTransaction = 0;

  List<Transaction> _pendingTransactions = [];
  Stream<Transaction> _inboundTransactionStream;
  StreamController<Transaction> _inboundTransactionStreamController;

  BasicDartNetworkRepository({String getEndpoint, String sendEndpoint}) {
    // _getEndPoint = getEndpoint ?? "$defaultServerAddress/api/get_items";
    _getEndPoint = getEndpoint ?? "$defaultServerAddress/api/get_transactions";
    _sendEndPoint =
        sendEndpoint ?? "$defaultServerAddress/api/send_transactions";

    _itemAddedStreamController = StreamController.broadcast();
    _itemChangedStreamController = StreamController.broadcast();
    _itemRemovedStreamController = StreamController.broadcast();

    _itemAddedStream = _itemAddedStreamController.stream;
    _itemChangedStream = _itemChangedStreamController.stream;
    _itemRemovedStream = _itemRemovedStreamController.stream;

    _inboundTransactionStreamController = StreamController.broadcast();
    _inboundTransactionStream = _inboundTransactionStreamController.stream;
  }

  Future<void> addItem(Item item) async {
    _inboundTransactionStreamController.add(Transaction(
        id: getCurrentEpoch(), type: TransactionType.Add, item: item));
  }

  Future<void> changeItem(Item item) async {
    _inboundTransactionStreamController.add(Transaction(
        id: getCurrentEpoch(), type: TransactionType.Modify, item: item));
  }

  Future<void> removeItem(Item item) async {
    _inboundTransactionStreamController.add(Transaction(
        id: getCurrentEpoch(), type: TransactionType.Remove, item: item));
  }

  @override
  Future<void> fetch() async {
    await _fetch();
    return null;
  }

  @override
  void start() {
    _inboundTransactionStream.listen((transaction) {
      _pendingTransactions.add(transaction);
      switch (transaction.type) {
        case TransactionType.Add:
          _itemAddedStreamController.add(transaction.item);
          break;
        case TransactionType.Modify:
          _itemChangedStreamController.add(transaction.item);
          break;
        case TransactionType.Remove:
          _itemRemovedStreamController.add(transaction.item);
          break;
      }
    });
    _fetch();
  }

  _fetch() async {
    List<Transaction> transactionList = await _getTransactionsFromServer();
    print("Transaction List: ${transactionList.map((e) => e.item.title)}");
    if (transactionList.isNotEmpty)
      lastReceivedTransaction = transactionList.last.id;
    var pendingTransactionIds = _pendingTransactions.map((e) => e.id);
    for (var transaction in transactionList) {
      if (pendingTransactionIds.contains(transaction.id)) {
        // Its a echo transaction so we must omit it

        continue;
      }
      switch (transaction.type) {
        case TransactionType.Add:
          print("The ${transaction.item.title} is Added By Repository");
          _itemAddedStreamController.add(transaction.item);
          // print("Repository Added ${transaction.item.title} From Fetch");
          break;
        case TransactionType.Modify:
          print("The ${transaction.item.title} is Changed By Repository");
          _itemChangedStreamController.add(transaction.item);
          break;
        case TransactionType.Remove:
          print("The ${transaction.item.title} is Removed By Repository");
          _itemRemovedStreamController.add(transaction.item);
          break;
      }
      // TODO:Find a solution for syncronizing streams to replace this hack
      // One possible workaround is to get state (instead of transactions)
      // whenever the app starts or the number of transactions is high.
      await Future.delayed(Duration(microseconds: 1));
    }
    // Isnt it better to flush the pendingTransactions in
    // _sendTransactionsToServer?
    _pendingTransactions = [];
  }

  // TODO: Is This Even Needed?
  @override
  Future<void> syncToServer() async {
    await _sendTransactionsToServer();
  }

  @override
  Future<void> syncWithServer() async {
    await _sendTransactionsToServer();
    await _fetch();
  }

  _getTransactionsFromServer() async {
    //TODO: Fix THis
    _getEndPoint =
        "$defaultServerAddress/api/get_transactions?from=$lastReceivedTransaction";
    var url = Uri.parse(_getEndPoint);
    var rawString = await http.read(url);
    // var result = deserializeItemList(rawString);
    var result = deserializeTransactions(rawString);
    return result;
  }

  _sendTransactionsToServer() async {
    var url = Uri.parse(_sendEndPoint);
    await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_pendingTransactions));
  }

  @override
  Stream<Item> getItemAddedStream() {
    return _itemAddedStream;
  }

  @override
  Stream<Item> getItemChangedStream() {
    return _itemChangedStream;
  }

  @override
  Stream<Item> getItemRemovedStream() {
    return _itemRemovedStream;
  }
}

//class DartNetworkWithCacheRepository extends BasicDartNetworkRepository {
//  StreamController<List<Item>> _cachedItemListStreamController;
//  Stream<List<Item>> _cachedItemListStream;

//  List<Item> _cachedItemList = [];

//  DateTime lastFetchTime;

//  Duration _cacheMaxAge;

//  DartNetworkWithCacheRepository(
//      {String getEndpoint, String sendEndpoint, Duration cacheMaxAge})
//      : super(getEndpoint: getEndpoint, sendEndpoint: sendEndpoint) {
//    _cacheMaxAge = cacheMaxAge ?? Duration(seconds: 10);
//    _cachedItemListStreamController = StreamController();
//    _cachedItemListStream = _cachedItemListStreamController.stream;
//    // Everytime the network stream gets a new itemList from server, it updates
//    // the client side itemList stream as well.
//    _cachedItemListStream.listen((event) {
//      _itemListStreamController.add(event);
//      _cachedItemList = event;
//      _maybeSync();
//    });
//  }

//  @override
//  _fetch() async {
//    var itemListFromServer = await _getItemsFromServer();
//    _cachedItemListStreamController.add(itemListFromServer);
//    lastFetchTime = DateTime.now();
//  }

//  @override
//  Future<void> updateItems(List<Item> itemList) async {
//    _cachedItemListStreamController.add(itemList);
//    return;
//  }

//  @override
//  Future<void> syncItems() async {
//    await _sync();
//  }

//  _maybeSync() async {
//    if (DateTime.now().difference(lastFetchTime) > _cacheMaxAge) {
//      await _sync();
//    }
//  }

//  _sync() async {
//    await _sendItemsToServer(_cachedItemList);
//    await _fetch();
//  }
//}

//// This would be the real repository connected
//class NativeRepository implements Repository {
//  StreamController<List<Item>> _itemListStreamController;
//  Stream<List<Item>> itemListStream;

//  NativeRepository() {
//    itemListStream = _itemListStreamController.stream;
//  }

//  void onDataRecieved(String rawData) {
//    List<Item> currentList = deserializeItemList(rawData);
//    _itemListStreamController.add(currentList);
//  }

//  void onClose() {
//    _itemListStreamController.close();
//  }

//  @override
//  Stream<List<Item>> getItemListStream() {
//    return itemListStream;
//  }

////TODO: Implement Update Items.
//  @override
//  Future<void> updateItems(List<Item> itemList) {
//    return null;
//  }

//  @override
//  void start() {
//    // TODO: implement start
//  }

//  @override
//  Future<void> syncItems() {
//    // TODO: implement syncItems
//    throw UnimplementedError();
//  }
//}
