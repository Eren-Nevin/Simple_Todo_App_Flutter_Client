import 'package:flutter/material.dart';

import './model.dart';

class ViewItem {
  ViewItem(
      this.item, this.removeHandler, this.detailsHandler, this.starHandler);
  Item item;
  VoidCallback removeHandler;
  VoidCallback detailsHandler;
  VoidCallback starHandler;
}
