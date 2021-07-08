import 'package:flutter/foundation.dart';

String getBaseUrl() {
  if (kReleaseMode) {
    return "https://dinkedpawn.com:9999";
  } else {
    return "http://localhost:9999";
  }
}
