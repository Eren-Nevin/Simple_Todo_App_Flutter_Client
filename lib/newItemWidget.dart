import 'package:flutter/material.dart';

class NewItemWidget extends StatelessWidget {
  ValueChanged<String> newItemTextSubmit;

  NewItemWidget(this.newItemTextSubmit);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: TextField(
          onSubmitted: newItemTextSubmit,
          maxLines: 1,
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: "Enter New Item",
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(6.0))),
          autofocus: true,
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0));
  }
}
