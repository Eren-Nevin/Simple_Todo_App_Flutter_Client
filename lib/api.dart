import 'dart:convert';
import 'dart:math';

import './model.dart';
import 'package:http/http.dart' as http;

// This is because on android emulator localhost is accessible as 10.0.2.2
const serverAddress = "http://localhost:9999";

getItemsFromServer() async {
  var url = Uri.parse("$serverAddress/api/get_items");
  List<dynamic> response = json.decode(await http.read(url));
  var result = response
      .map((value) => Item(value['id'], value['title'], value['timestamp']))
      .toList();
  return result;
}

sendItemsToServer(itemList) async {
  var url = Uri.parse("$serverAddress/api/send_items");
  await http.post(url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(itemList));
}
