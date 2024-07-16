import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/dashboard_page.dart';
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
        backgroundColor: const Color.fromARGB(255, 85, 85, 85),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Calorie Tracking",
            style: TextStyle(color: Colors.white)),
        actions: [
          // Move the actions inside AppBar
          IconButton(
            key: const Key('logoutButton'),
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(237, 255, 134, 21),
              ),
              child: Text('Fusion Workout',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              key: const Key('homeButton'),
              title: const Text('Home'),
              // Corrected onTap method for navigating to the WorkoutsPage
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPage()),
                );
              },
            ),
            ListTile(
              key: const Key('workoutsButton'),
              title: const Text('Workouts'),
              // Corrected onTap method for navigating to the WorkoutsPage
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutsPage()),
                );
              },
            ),
            ListTile(
              key: const Key('calorieButton'),
              title: const Text('Calorie Tracking'),
              // Corrected onTap method for navigating to the WorkoutsPage
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalorieTrackingPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SearchAnchor(
            builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            controller: controller,
            padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0)),
            onTap: () {
              controller.openView();
            },
            onChanged: (_) {
              controller.openView();
            },
            leading: const Icon(Icons.search),
          );
        }, suggestionsBuilder:
                (BuildContext context, SearchController controller) {
          return List<ListTile>.generate(5, (int index) {
            final String item = 'item $index';
            return ListTile(
              title: Text(item),
              onTap: () {
                setState(() {
                  controller.closeView(item);
                });
              },
            );
          });
        }),
      ),
    );
  }
}
