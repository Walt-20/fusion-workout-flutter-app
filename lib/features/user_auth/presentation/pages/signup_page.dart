// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/login_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/form_container_widget.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                hintText: "Username",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 85, 85, 85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                        color: Color.fromARGB(237, 255, 134, 21),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Have an account?"),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false);
                    },
                    child: Text(
                      "Login",
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
    );
  }
}
