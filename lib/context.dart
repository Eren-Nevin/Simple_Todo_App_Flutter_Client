import 'package:flutter/foundation.dart';

String getBaseUrl() {
  if (kReleaseMode) {
    return "https://todo.dinkedpawn.com";
  } else {
    return "https://todo.dinkedpawn.com";
    // return "http://localhost:9999";
  }
}
