// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/form_container_widget.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "On Boarding",
          style: TextStyle(
            color: Color.fromARGB(237, 255, 134, 21),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 85, 85, 85),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome ${_auth.user?.displayName ?? 'User'} to Fusion Workouts!",
                style: TextStyle(
                  color: Color.fromARGB(237, 255, 134, 21),
                  fontWeight: FontWeight.bold,
                  fontSize: 27,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                hintText: "Name",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                hintText: "Phone Number",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                hintText: "Age",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                hintText: "Sex",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                hintText: "Weight",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                hintText: "Height",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                hintText: "Workout availability (within a seven day peroid)",
                isPasswordField: false,
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: _onboard,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 85, 85, 85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                          color: Color.fromARGB(237, 255, 134, 21),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onboard() {}
}
