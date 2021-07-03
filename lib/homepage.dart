import 'package:flutter/material.dart';
import 'package:list/pages/listPage.dart';
import 'package:list/pages/authenticationPage.dart';

import './viewModel.dart';
import 'utilities.dart';

// TODO: Make another page for main page that contains widgets that are
// available when user is logged in and make this switch between that page and
// authentication page
class ActivePage extends StatefulWidget {
  final String title;

  ActivePage({Key key, this.title}) : super(key: key);

  @override
  _ActivePageState createState() => _ActivePageState();
}

class _ActivePageState extends State<ActivePage> {
  bool authenticated = false;
  Map<String, dynamic> credentials;

  onLogout() {
    setState(() {
      authenticated = false;
    });
  }

  void onSuccessfulLogin(Map<String, dynamic> credentials) {
    setState(() {
      // _viewModel.connect(credentials);
      this.credentials = credentials;
      authenticated = true;
    });
  }

  _ActivePageState();

  @override
  Widget build(BuildContext context) {
    return authenticated
        ? ListPage(this.credentials, onLogout)
        : AuthenticationPage(onSuccessfulLogin);
  }
}

//TODO: Have One Tab in Navigation Bar For Private List, The Other Two Can Be
//Groceries & Family Tasks Which Are Shared Among A Family.

