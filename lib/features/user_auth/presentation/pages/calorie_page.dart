import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/workouts_page.dart';

class CalorieTrackingPage extends StatefulWidget {
  const CalorieTrackingPage({super.key});

  @override
  State<CalorieTrackingPage> createState() => _CalorieTrackingPageState();
}

class _CalorieTrackingPageState extends State<CalorieTrackingPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _auth = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 85, 85, 85),
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text("Calorie Tracking",
            style: TextStyle(color: Colors.white)),
        actions: [
          // Move the actions inside AppBar
          IconButton(
            key: Key('logoutButton'),
            icon: Icon(Icons.logout),
            onPressed: () => _auth.signOut(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(237, 255, 134, 21),
              ),
              child: Text('Fusion Workout',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              key: Key('workoutsButton'),
              title: const Text('Workouts'),
              // Corrected onTap method for navigating to the WorkoutsPage
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkoutsPage()),
                );
              },
            ),
            ListTile(
              key: Key('calorieButton'),
              title: const Text('Calorie Tracking'),
              // Corrected onTap method for navigating to the WorkoutsPage
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CalorieTrackingPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
