// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/my_button.dart';
import 'package:fusion_workouts/features/user_auth/provider/tokenprovider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variable to track if the widget is mounted
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(
            color: Color.fromARGB(237, 255, 134, 21),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 85, 85, 85),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome, get back to work!",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                FormContainerWidget(
                  fieldKey: Key("emailField"),
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  fieldKey: Key("passwordField"),
                  controller: _passwordController,
                  hintText: "Password",
                  isPasswordField: true,
                ),
                SizedBox(
                  height: 30,
                ),
                MyButton(
                  fieldKey: Key("loginButton"),
                  text: "Login",
                  onTap: _login,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      key: Key('signupButton'),
                      onTap: widget.onTap,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color.fromARGB(237, 255, 134, 21),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchOAuthToken() async {
    final url = Uri.parse(
        'http://proxy-backend-api-fusion-env.eba-semam5sh.us-east-2.elasticbeanstalk.com/get-token');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint("fetchOAuthToken ${jsonData['access_token']}");
        if (mounted) {
          Provider.of<TokenProvider>(context, listen: false)
              .updateToken(jsonData['access_token']);
        }
      } else {
        FirebaseAuth.instance.signOut();
        throw Exception('Failed to fetch OAuth2 token');
      }
    } catch (e) {
      FirebaseAuth.instance.signOut();
    }
  }

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showAlertMessage("Please enter both your email and password");
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email, password);
      await fetchOAuthToken();
    } on FirebaseAuthException catch (e) {
      showAlertMessage(e.code);
    }
  }

  void showAlertMessage(String message) {
    if (message == 'user-not-found') {
      message = 'User not found';
    } else if (message == 'wrong-password') {
      message = 'Wrong password';
    } else if (message == 'invalid-email') {
      message = 'Invalid email';
    } else if (message == 'user-disabled') {
      message = 'User disabled';
    } else if (message == 'too-many-requests') {
      message = 'Too many requests';
    } else if (message == 'operation-not-allowed') {
      message = 'Operation not allowed';
    } else if (message == 'network-request-failed') {
      message = 'Network request failed';
    } else {
      message = message;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(237, 255, 134, 21),
        title: Center(
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
