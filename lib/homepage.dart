import 'package:flutter/material.dart';
import 'package:list/pages/listPage.dart';
import 'package:list/pages/authenticationPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:list/context.dart';

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

  _ActivePageState();

  // TODO: What to do on unsuccessful logout from server
  // Should we even await these?
  onLogout(Map<String, dynamic> credentials) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    // await prefs.setString('userToken', credentials['token']);
    final rawResponse = await http.post(
        Uri.parse("${getBaseUrl()}/api/auth/logout"),
        body: json.encode(credentials));
    final response = json.decode(rawResponse.body);
    if (response['success']) {
      // return {'token': response['message']};
    } else {
      // return {'error': response['message']};
    }
    setState(() {
      authenticated = false;
    });
  }

  onSuccessfulLogin(Map<String, dynamic> credentials) async {
    setState(() {
      // _viewModel.connect(credentials);
      this.credentials = credentials;
      print(credentials);
      authenticated = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Should we save the token if the same token is already saved?
    await prefs.setString('userToken', credentials['token']);
  }

  @override
  Widget build(BuildContext context) {
    return authenticated
        ? ListPage(this.credentials, onLogout)
        : AuthenticationPage(onSuccessfulLogin);
  }
}
    
//TODO: Have One Tab in Navigation Bar For Private List, The Other Two Can Be
//Groceries & Family Tasks Which Are Shared Among A Family.

