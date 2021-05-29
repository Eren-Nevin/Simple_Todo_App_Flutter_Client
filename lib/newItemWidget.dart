import 'package:flutter/material.dart';

class NewItemWidget extends StatefulWidget {
  final ValueChanged<String> newItemTextSubmit;
  final ValueNotifier<bool> addingNewItem;

  NewItemWidget(this.newItemTextSubmit, this.addingNewItem, {Key key})
      : super(key: key);

  @override
  _NewItemWidgetState createState() =>
      _NewItemWidgetState(newItemTextSubmit, addingNewItem);
}

class _NewItemWidgetState extends State<NewItemWidget> {
  ValueChanged<String> newItemTextSubmit;
  ValueNotifier<bool> addingNewItem;
  bool isVisible = false;
  // String textFieldText = "";

  _NewItemWidgetState(this.newItemTextSubmit, this.addingNewItem) {
    addingNewItem.addListener(() {
      setState(() {
        isVisible = addingNewItem.value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: Container(
          child: TextField(
            onSubmitted: (str) {
              newItemTextSubmit(str);
              addingNewItem.value = false;
            },
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
          padding: EdgeInsets.symmetric(vertical: 8.0)),
      visible: isVisible,
    );
  }
}
