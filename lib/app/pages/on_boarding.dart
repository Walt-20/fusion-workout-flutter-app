// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/app/models/entry.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/app/pages/dashboard_page.dart';
import 'package:fusion_workouts/app/widgets/form_container_widget.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();

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
      body: SingleChildScrollView(
        child: Center(
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
                  controller: _nameController,
                  key: Key('name'),
                  hintText: "Name",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 10,
                ),
                // FormContainerWidget(
                //   controller: _phoneNumberController,
                //   key: Key('phoneNumber'),
                //   hintText: "Phone Number",
                //   isPasswordField: false,
                // ),
                // SizedBox(
                //   height: 10,
                // ),
                FormContainerWidget(
                  controller: _ageController,
                  key: Key('age'),
                  hintText: "Age",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _sexController,
                  key: Key('sex'),
                  hintText: "Sex",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _weightController,
                  key: Key('weight'),
                  hintText: "Weight",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _heightController,
                  key: Key('height'),
                  hintText: "Height",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _availabilityController,
                  key: Key('availability'),
                  hintText: "Workout availability (within a seven day peroid)",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  key: Key('onboardButton'),
                  onTap: _onboard,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(237, 255, 134, 21),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "Update Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onboard() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );
      try {
        _auth.writeEntryToFirebase(
          Entry(
            username: _nameController.text,
            email: currentUser.email ?? '',
            name: _nameController.text,
            phoneNumber: _phoneNumberController.text,
            age: _ageController.text,
            sex: _sexController.text,
            weight: _weightController.text,
            height: _heightController.text,
            availability: _availabilityController.text,
          ),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DashboardPage()));
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          print('You do not have permission to perform this operation.');
        } else {
          print("Error Writing to Database");
        }
      } catch (e) {
        print("Error Writing to Database");
      }
    } else {
      AlertDialog(
        title: Text("Error"),
        content: Text("No User signed in!"),
      );
    }
  }
}
