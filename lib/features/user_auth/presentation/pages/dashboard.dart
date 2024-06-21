// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(
            color: Color.fromARGB(237, 255, 134, 21),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 85, 85, 85),
      ),
      body: Center(
        child: Text("Welcome to Fusion Workout!"),
      ),
    );
  }
}
