import 'package:flutter/material.dart';
import 'package:list/viewModel.dart';

import './homepage.dart' show ActivePage;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ActivePage(),
    );
  }
}
