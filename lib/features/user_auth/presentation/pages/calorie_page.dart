import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/dashboard_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/workouts_page.dart';
import 'package:fusion_workouts/features/user_auth/provider/tokenprovider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalorieTrackingPage extends StatefulWidget {
  const CalorieTrackingPage({Key? key}) : super(key: key);

  @override
  State<CalorieTrackingPage> createState() => _CalorieTrackingPageState();
}

class _CalorieTrackingPageState extends State<CalorieTrackingPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final _auth = FirebaseAuthService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _focusedDay = day;
      _selectedDay = day;
    });

    Navigator.pop(context);
  }

  void _searchFoods(String query) async {
    try {
      List<dynamic> results = [];
      debugPrint("Search results: $results");
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            backgroundColor: Color.fromARGB(237, 255, 134, 21),
            title: Center(
              child: Text(
                "Error communicating with API",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = Provider.of<TokenProvider>(context).accessToken;
    debugPrint("access token $accessToken");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 85, 85, 85),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Calorie Tracking",
            style: TextStyle(color: Colors.white)),
        actions: [
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Select Day"),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: TableCalendar(
                          availableGestures: AvailableGestures.all,
                          selectedDayPredicate: (day) =>
                              isSameDay(day, _focusedDay),
                          focusedDay: _focusedDay,
                          firstDay: DateTime.utc(2020, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          onDaySelected: _onDaySelected,
                        ),
                      ),
                    );
                  },
                );
              },
              child: Text(
                _selectedDay == null || isSameDay(_selectedDay!, DateTime.now())
                    ? "Today"
                    : DateFormat('yyyy-MM-dd').format(_selectedDay!),
                style: TextStyle(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    // Handle onChanged if needed
                  },
                  onSubmitted: (query) {
                    _searchFoods(query); // Trigger search on submit
                  },
                  leading: const Icon(Icons.search),
                  trailing: [
                    IconButton(
                      onPressed: () {
                        // Handle microphone button press if needed
                      },
                      icon: const Icon(Icons.mic),
                    ),
                  ],
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return [];
                // Optionally build suggestions list UI
                // return ListView.builder(
                //   itemCount: _searchResults.length,
                //   itemBuilder: (context, index) {
                //     return ListTile(
                //       title: Text(_searchResults[index]['food_name']),
                //       subtitle: Text(_searchResults[index]['brand_name'] ?? ''),
                //       onTap: () {
                //         // Handle selection of search result if needed
                //       },
                //     );
                //   },
                // );
              },
            ),
          ),
        ],
      ),
    );
  }
}
