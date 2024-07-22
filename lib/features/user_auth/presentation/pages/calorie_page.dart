import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/meal_summary.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/dashboard_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/workouts_page.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum MealType { breakfast, lunch, dinner }

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
  num totalBreakfastCalories = 0;
  double totalBreakfastProtein = 0;
  double totalBreakfastCarbs = 0;
  num totalLunchCalories = 0;
  double totalLunchProtein = 0;
  double totalLunchCarbs = 0;
  num totalDinnerCalories = 0;
  double totalDinnerCarbs = 0;
  double totalDinnerProtein = 0;

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _focusedDay = day;
      _selectedDay = day;
    });

    Navigator.pop(context);
  }

  Future<void> _fetchSearchFood(String query) async {
    final url = Uri.parse('http://10.0.2.2:3000/search-food');

    try {
      final response =
          await http.get(Uri.parse('$url?searchExpression=$query'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final foods = List<Map<String, dynamic>>.from(jsonData);

        setState(() {
          _searchResults = foods;
        });
      } else {
        debugPrint("some error");
      }
    } catch (e) {
      debugPrint("some error $e");
    }
  }

  void _showAddToMealDialog(dynamic food) {
    MealType? _selectedMeal = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Food"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: MealType.values.map((meal) {
                return RadioListTile<MealType>(
                  title: Text(meal.toString().split('.').last),
                  value: meal,
                  groupValue: _selectedMeal,
                  onChanged: (MealType? value) {
                    _selectedMeal = value;
                    Navigator.of(context).pop();
                    _addToMeal(food, value);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _addToMeal(dynamic food, MealType? mealType) {
    // Here you would add the food to the selected meal.
    // This is a placeholder for your implementation.
    debugPrint(
        "Added ${food.toString()} to ${mealType.toString().split('.').last}");

    // if (mealType.toString().split('.').last == "breakfast") {
    //   totalBreakfastCalories += food['Calories'];
    //   totalBreakfastProtein += food['Protein'];
    //   totalBreakfastCarbs += food['Carbs'];
    // } else if (mealType.toString().split('.').last == 'lunch') {
    //   totalLunchCalories += food['calories'];
    //   totalLunchProtein += food['protein'];
    //   totalLunchCarbs += food['carbs'];
    // } else if (mealType.toString().split('.').last == 'dinner') {
    //   totalDinnerCalories += food['calories'];
    //   totalDinnerProtein += food['protein'];
    //   totalDinnerCarbs += food['carbs'];
    // } else {
    //   debugPrint("some error");
    // }
  }

  @override
  Widget build(BuildContext context) {
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
                    _fetchSearchFood(query); // Trigger search on submit
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
                // Check if _searchResults is empty and return accordingly
                if (_searchResults.isEmpty) {
                  return [
                    const Center(child: Text('No results found'))
                  ]; // Wrap the Widget in a list
                } else {
                  // Return a list of Widgets directly
                  return List<Widget>.generate(
                    _searchResults.length,
                    (index) {
                      final food = _searchResults[index];
                      return ListTile(
                        title: Text(food['food_name']),
                        subtitle: Text(food['food_description'] ?? ''),
                        onTap: () {
                          debugPrint("Tapped");
                          // Handle onTap if needed
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MealSummaryWidget(
                mealName: 'Breakfast',
                totalCalories: totalBreakfastCalories,
                proteinIntake: totalBreakfastProtein,
                carbIntake: totalBreakfastCarbs,
              ),
              MealSummaryWidget(
                mealName: 'Lunch',
                totalCalories: totalLunchCalories,
                proteinIntake: totalLunchProtein,
                carbIntake: totalLunchCarbs,
              ),
              MealSummaryWidget(
                mealName: 'Breakfast',
                totalCalories: totalDinnerCalories,
                proteinIntake: totalDinnerProtein,
                carbIntake: totalDinnerCarbs,
              ),
            ],
          ),
          // This is for showing the selected items in a separate ListView
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final food = _searchResults[index];
                return ListTile(
                  title: Text(food['food_name']),
                  subtitle: Text(food['food_description'] ?? ''),
                  onTap: () {
                    _showAddToMealDialog(food);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
