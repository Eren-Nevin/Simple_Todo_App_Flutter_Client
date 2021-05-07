import 'package:flutter/material.dart';

import './model.dart';

class ViewItem {
  ViewItem(this.item, this.tapHandler);
  Item item;
  VoidCallback tapHandler;
}
