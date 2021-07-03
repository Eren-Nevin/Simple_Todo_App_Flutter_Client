import 'dart:async';
import 'dart:convert';
import './utilities.dart';
import './model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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

//TODO: Make it type safe
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
  void connect(Map<String, dynamic> credentials);
  void disconnect();

  //TODO: Make it gettable by a getter
  ValueNotifier<bool> dataReset;
}

// This is the stand-in repository that connects to server for each action
// without any caching or smart behavior.
class WebsocketNetworkRepository implements Repository {
  Stream<Item> _itemAddedStream;
  Stream<Item> _itemChangedStream;
  Stream<Item> _itemRemovedStream;

  StreamController<Item> _itemAddedStreamController;
  StreamController<Item> _itemChangedStreamController;
  StreamController<Item> _itemRemovedStreamController;

  String defaultServerAddress = "http://localhost:9999";
  String _getEndPoint;
  // String _getTransactionsEndPoint;
  String _sendEndPoint;
  //TODO: Remove This
  int lastReceivedTransaction = 0;

  List<Transaction> _currentTransactions = [];
  List<Transaction> _pendingTransactions = [];
  List<Transaction> _previousPendingTransactions = [];

  Stream<Transaction> _inboundTransactionStream;
  StreamController<Transaction> _inboundTransactionStreamController;
  IO.Socket socket;
  ValueNotifier<bool> dataReset = ValueNotifier(false);
  ValueNotifier<bool> websocketConnected = ValueNotifier(false);

  WebsocketNetworkRepository({String getEndpoint, String sendEndpoint}) {
    // _getEndPoint = getEndpoint ?? "$defaultServerAddress/api/get_items";

    // Use real deployed server instead of localhost when on release not debug
    if (kReleaseMode) {
      defaultServerAddress = "https://dinkedpawn.com:9999";
    }
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

  // These are called by the viewModel when client is adding/removing/changing
  // items.
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

  // These are listened by the viewModel to know when an item is
  // added/removed/changed.
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

  @override
  void connect(Map<String, dynamic> credentials) {
    createWebSocket(credentials['token']);
    addWebSocketOnEventsListeners();
    addWebSocketOnConnectListener();
    addWebSocketOnDisconnectListener();
    // Listen on item changes coming from viewModel (e.g. user adds a new item).
    startListeningOnInputTransactions();
    connectWebSocket();
  }

  //TODO: Make proper destructor.
  @override
  void disconnect() {
    socket.disconnect();
  }

  void startListeningOnInputTransactions() {
    _inboundTransactionStream.listen((transaction) {
      // We always add the transaction to current trasnaction. This doens't
      // pose any further problems in sync since server doesn't echo the
      // transaction to ourself later (no echo).
      _currentTransactions.add(transaction);

      // If we're connected, send the transaction immediately, otherwise add it
      // to the pending transactions that would be sent to server when
      // connection is established.
      if (websocketConnected.value) {
        //TODO: Implement cases where there is connection but no
        //acknowledgement.
        socket.emitWithAck('send_transaction_to_server', transaction,
            ack: (data) {
          print("Acknowledged");
        });
      } else {
        _pendingTransactions.add(transaction);
      }

      //TODO: Cancel Pending Emits On Disconnect

      // Add transaction to streams that would be consumed by viewModel and
      // widgets down the line.
      _pushTransactionIntoStreams(transaction);
    });
  }

  void createWebSocket(String token) {
    socket = IO.io(
        "$defaultServerAddress/socket.io",
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .setQuery({
              'token': token
              // r"sha256$x7j72cOQ$66ac27b02df0456ca079215a20f27bad17ff0ebd25456e3bb6ecf1410aa24707"
            })
            .disableAutoConnect() // disable auto-connection
            .build());
  }

  void addWebSocketOnEventsListeners() {
    // This is called when server pushes a normal (not out of order) transaction to client.
    socket.on('send_transaction_to_client', (rawTransaction) {
      print("Received $rawTransaction");
      Transaction transaction = rawTransactionConvertor(rawTransaction);

      // Its a normal transaction. We just need to add it to the current
      // ones.
      // Even though we don't echo the sent transaction back to the sender we
      // need to still check for an echoed transaction like we did in _fetch().
      // This is an added measure to make sure no duplicate transaction ends up
      // in the app.

      if (!_currentTransactions.contains(transaction)) {
        _currentTransactions.add(transaction);
        _pushTransactionIntoStreams(transaction);
      }
    });

    socket.on('send_reset_transactions_to_client', (rawTransactions) {
      // This happens when server detects that one of the clients tried to
      // push a transaction to server that would change the transaction
      // history. In this situation it pushes all (or a reduced) of newly
      // updated transactions in one go to client. The clients are supposed to
      // reset all their own data (e.g. items) and reinitiate with the
      // provided transactions.
      // Note that this doens't get triggered for the out of sync client
      // itself, but for other clients currently connected.
      // print(rawTransactions.runtimeType);
      print("Received Reset Transactions $rawTransactions");
      var transactionList =
          rawTransactions.map((e) => rawTransactionConvertor(e)).toList();
      // print(transactionList.runtimeType);
      //TODO: Why this syntactic gymanstic is needed here?
      List<Transaction> myTransactionList = [...transactionList];
      _initializeItemList(myTransactionList);
    });
  }

  void addWebSocketOnConnectListener() {
    socket.onConnect((_) {
      print('Connected To Websocket');
      websocketConnected.value = true;

      //TODO: Make this useful for authenticating on the server.

      // When client connects, it first ends all of its pending transactions to
      // server (as a single message payload) then it waits for server for an
      // acknowledgement has the whole currect trasnactions timeline which the
      // client uses to initialize itself.
      socket
          .emitWithAck('client_connect_sync', json.encode(_pendingTransactions),
              ack: (List<dynamic> data) {
        // print(data.runtimeType);
        List<Transaction> transactionList =
            data.map((e) => rawTransactionConvertor(e)).toList();
        _initializeItemList(transactionList);
      });
      // socket.emitWithAck(
      //         'send_transaction_to_server',
      //         "",
      //         ack: (data) {
      //             print("Acknowledged");
      //         });
    });
  }

  void addWebSocketOnDisconnectListener() {
    socket.onDisconnect((_) {
      print('Disconnected From Websocket');
      websocketConnected.value = false;
    });
  }

  void connectWebSocket() {
    socket.connect();
  }

  void _initializeItemList(List<Transaction> transactionList) async {
    _pendingTransactions = [];

    print("Removing All Items In Current Transaction List");
    for (var transaction in _currentTransactions) {
      _itemRemovedStreamController.add(transaction.item);
      //TODO: Does it need the delay hack?
    }

    _currentTransactions = [...transactionList];

    print("Initializing Items Into Current Transaction List");
    for (var transaction in _currentTransactions) {
      // Transaction transaction = rawTransactionConvertor(e);
      _pushTransactionIntoStreams(transaction);
      await Future.delayed(Duration(microseconds: 1));
    }
  }

  _pushTransactionIntoStreams(Transaction transaction) {
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
  }

  // int _getMostRecentTransactionId() {
  //   int maxId = 0;
  //   for (var transaction in _currentTransactions) {
  //     if (maxId < transaction.id) maxId = transaction.id;
  //   }
  //   return maxId;
  // }

  // Although we don't need the fetch & sync family of methods, we just comment
  // their implementation only for now.

  @override
  Future<void> fetch() async {
    // await _fetch();
    // return null;
  }

  _fetch() async {
    //print("Fetch Called");
    ////TODO: We need a reducer to make sure not overwhelm the viewModel and views
    ////with a huge transaction list.
    //List<Transaction> transactionList = await _getTransactionsFromServer();
    //print("Transaction List: ${transactionList.map((e) => e.item.title)}");
    //if (transactionList.isNotEmpty)
    //  lastReceivedTransaction = transactionList.last.id;
    //var pendingTransactionIds = _previousPendingTransactions.map((e) => e.id);
    //for (var transaction in transactionList) {
    //  if (pendingTransactionIds.contains(transaction.id)) {
    //    // Its a echo transaction so we must omit it

    //    continue;
    //  }
    //  _applyTransactionIntoStreams(transaction);
    //  // TODO:Find a solution for syncronizing streams to replace this hack
    //  // One possible workaround is to get state (instead of transactions)
    //  // whenever the app starts or the number of transactions is high.
    //  await Future.delayed(Duration(microseconds: 1));
    //}
    //// Isnt it better to flush the pendingTransactions in
    //// _sendTransactionsToServer?
    //// _pendingTransactions = [];
  }

  @override
  Future<void> syncToServer() async {
    // await _sendTransactionsToServer();
    // _previousPendingTransactions = [..._pendingTransactions];
    // _pendingTransactions = [];
  }

  @override
  Future<void> syncWithServer() async {
    // // await _sendTransactionsToServer();
    // await syncToServer();
    // await _fetch();
  }

  _getTransactionsFromServer() async {
    ////TODO: Fix THis
    //_getEndPoint =
    //    "$defaultServerAddress/api/get_transactions?from=$lastReceivedTransaction";
    //var url = Uri.parse(_getEndPoint);
    //var rawString = await http.read(url);
    //// var result = deserializeItemList(rawString);
    //var result = deserializeTransactions(rawString);
    //return result;
  }

  _sendTransactionsToServer() async {
    // var url = Uri.parse(_sendEndPoint);
    // await http.post(url,
    //     headers: {'Content-Type': 'application/json'},
    //     body: json.encode(_pendingTransactions));
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
