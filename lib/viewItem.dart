import 'package:flutter/material.dart';

import './model.dart';

class ViewItem {
  ViewItem(this.item, this.removeHandler);
  Item item;
  VoidCallback removeHandler;
  VoidCallback detailsHandler;
}
