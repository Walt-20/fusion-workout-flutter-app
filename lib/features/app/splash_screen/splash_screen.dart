// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => widget.child!),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Welcome to Fusion Workouts!",
          style: TextStyle(
              color: Color.fromARGB(237, 255, 134, 21),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
      ),
    );
  }
}
