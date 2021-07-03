import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Widget authenticationWidgetBuilder(
    void Function(Map<String, dynamic>) onSuccessfulLogin) {}

class AuthenticationPage extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSuccessfulLogin;

  AuthenticationPage(this.onSuccessfulLogin);

  @override
  _AuthenticationPageState createState() =>
      _AuthenticationPageState(onSuccessfulLogin);
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final void Function(Map<String, dynamic>) onSuccessfulLogin;
  _AuthenticationPageState(this.onSuccessfulLogin);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
          backgroundColor: Colors.indigo,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 24.0,
        ),
        body: Container(
          color: Colors.indigo,
          child: AuthenticationBodyWidget(this.onSuccessfulLogin),
          padding: EdgeInsets.symmetric(vertical: 8.0),
        ));
  }
}

class AuthenticationBodyWidget extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSuccessfulLogin;

  AuthenticationBodyWidget(this.onSuccessfulLogin);
  @override
  _AuthenticationBodyWidgetState createState() {
    return _AuthenticationBodyWidgetState(onSuccessfulLogin);
  }
}

class _AuthenticationBodyWidgetState extends State<AuthenticationBodyWidget> {
  final void Function(Map<String, dynamic>) onSuccessfulLogin;
  String enteredEmail = "";
  String enteredPassword = "";
  String enteredProfile = "";
  bool authError = false;
  String authErrorMessage = "";
  bool isSigningUp = false;

  _AuthenticationBodyWidgetState(this.onSuccessfulLogin);

  // TODO: Create an object for both email-pass credentials and token ones.
  Future<Map<String, dynamic>> _authenticate(credentials) async {
    final rawResponse = await http.post(
        Uri.parse("http://127.0.0.1:8833/api/login"),
        body: json.encode(credentials));
    final response = json.decode(rawResponse.body);
    if (response['success']) {
      return {'token': response['message']};
    } else {
      return {'error': response['message']};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final credentials = {'email': email, 'password': password};
    final response = await _authenticate(credentials);
    return response;
  }

  Future<Map<String, dynamic>> signup(
      String email, String password, String profile) async {
    final rawResponse = await http.post(
        Uri.parse("http://127.0.0.1:8833/api/signup"),
        body: json.encode(
            {'email': email, 'password': password, 'profile': profile}));

    final signupResponse = json.decode(rawResponse.body);
    if (signupResponse['success']) {
      final loginResponse = login(email, password);
      return loginResponse;
    } else {
      return {'error': signupResponse['message']};
    }
  }

  Widget AuthFieldBuilder(String hint, ValueChanged<String> onChanged) {
    return Container(
        child: TextField(
          onChanged: onChanged,
          maxLines: 1,
          decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: hint,
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(6.0))),
          autofocus: true,
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthFieldBuilder("Email", (str) {
          enteredEmail = str;
        }),
        AuthFieldBuilder("Password", (str) {
          enteredPassword = str;
        }),
        Visibility(
          child: AuthFieldBuilder("Profile", (str) {
            enteredProfile = str;
          }),
          visible: isSigningUp,
        ),
        // TODO: Find a better place for displaying errors
        Visibility(
          child: Container(
              child: Text(authErrorMessage,
                  style: TextStyle(color: Colors.yellow, fontSize: 18.0)),
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
              alignment: Alignment.centerLeft),
          visible: authError,
        ),
        Container(
            child: ElevatedButton(
                onPressed: () async {
                  if (isSigningUp) {
                    print(enteredEmail + " " + enteredPassword);
                    final authResponse = await signup(
                        enteredEmail, enteredPassword, enteredProfile);
                    if (authResponse.containsKey('token')) {
                      onSuccessfulLogin(authResponse);
                    } else {
                      setState(() {
                        authErrorMessage = authResponse['error'];
                        authError = true;
                      });
                      print(authResponse['error']);
                    }
                  } else {
                    print(enteredEmail + " " + enteredPassword);
                    // final sampleToken = enteredEmail;
                    final authResponse =
                        await login(enteredEmail, enteredPassword);
                    if (authResponse.containsKey('token')) {
                      onSuccessfulLogin(authResponse);
                    } else {
                      setState(() {
                        authErrorMessage = authResponse['error'];
                        authError = true;
                      });
                      print(authResponse['error']);
                    }
                  }
                },
                child: Text(
                  isSigningUp ? "Signup" : "Login",
                  style: TextStyle(fontSize: 18.0),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(128.0, 48.0),
                )),
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            alignment: Alignment.centerLeft),
        Container(
            child: Column(children: [
              Text(
                  isSigningUp
                      ? "Already have an account?"
                      : "Create new account?",
                  style: TextStyle(fontSize: 20.0, color: Colors.white)),
              TextButton(
                  onPressed: () {
                    setState(() {
                      isSigningUp = true;
                    });
                  },
                  child: Text(isSigningUp ? "Login" : "Signup",
                      style: TextStyle(fontSize: 20.0)))
            ]),
            margin: EdgeInsets.all(16.0))
      ],
    );
  }
}
