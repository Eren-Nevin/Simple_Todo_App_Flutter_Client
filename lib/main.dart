import 'package:flutter/material.dart';
import 'package:list/viewModel.dart';

import './homepage.dart' show MyHomePage;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ViewModel _viewModel = ViewModel();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(_viewModel, title: 'List'),
    );
  }
}
