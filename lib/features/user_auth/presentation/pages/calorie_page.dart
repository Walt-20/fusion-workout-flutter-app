import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/meal_summary.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/dashboard_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/workouts_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/add_food_dialog.dart';
import 'package:intl/intl.dart';
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
  num totalBreakfastCalories = 0;
  double totalBreakfastProtein = 0;
  double totalBreakfastCarbs = 0;
  double totalBreakfastFats = 0;
  num totalLunchCalories = 0;
  double totalLunchProtein = 0;
  double totalLunchCarbs = 0;
  double totalLunchFats = 0;
  num totalDinnerCalories = 0;
  double totalDinnerCarbs = 0;
  double totalDinnerProtein = 0;
  double totalDinnerFats = 0;
  EdgeInsetsGeometry padding = EdgeInsets.all(8.0);

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _focusedDay = day;
      _selectedDay = day;
    });

    Navigator.pop(context);
  }

  void _addViaFoodWidgetDialog(MealType mealType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddFoodDialog(
          mealType: mealType,
          updateNutritionalValues: (double newTotalCalories,
              double newTotalProtein,
              double newTotalCarbs,
              double newTotalFats) {
            setState(() {
              switch (mealType) {
                case MealType.breakfast:
                  totalBreakfastCalories += newTotalCalories;
                  totalBreakfastProtein += newTotalProtein;
                  totalBreakfastCarbs += newTotalCarbs;
                  totalBreakfastFats += newTotalFats;
                  break;
                case MealType.lunch:
                  totalLunchCalories += newTotalCalories;
                  totalLunchProtein += newTotalProtein;
                  totalLunchCarbs += newTotalCarbs;
                  totalLunchFats += newTotalFats;
                  break;
                case MealType.dinner:
                  totalDinnerCalories += newTotalCalories;
                  totalDinnerProtein += newTotalProtein;
                  totalDinnerCarbs += newTotalCarbs;
                  totalDinnerFats += newTotalFats;
                  break;
                default:
                  debugPrint("Error: Invalid meal type");
                  break;
              }
            });
          },
        );
      },
    );
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
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
                    _selectedDay == null ||
                            isSameDay(_selectedDay!, DateTime.now())
                        ? "Today"
                        : DateFormat('yyyy-MM-dd').format(_selectedDay!),
                    style: TextStyle(),
                  ),
                ),
              ),
              MealSummaryWidget(
                mealName: 'Breakfast',
                totalCalories: totalBreakfastCalories,
                proteinIntake: totalBreakfastProtein,
                carbIntake: totalBreakfastCarbs,
                fatIntake: totalBreakfastFats,
                onTap: () {
                  _addViaFoodWidgetDialog(MealType.breakfast);
                },
              ),
              Padding(padding: padding),
              MealSummaryWidget(
                mealName: 'Lunch',
                totalCalories: totalLunchCalories,
                proteinIntake: totalLunchProtein,
                carbIntake: totalLunchCarbs,
                fatIntake: totalLunchFats,
                onTap: () {
                  _addViaFoodWidgetDialog(MealType.lunch);
                },
              ),
              Padding(padding: padding),
              MealSummaryWidget(
                mealName: 'Dinner',
                totalCalories: totalDinnerCalories,
                proteinIntake: totalDinnerProtein,
                carbIntake: totalDinnerCarbs,
                fatIntake: totalDinnerFats,
                onTap: () {
                  _addViaFoodWidgetDialog(MealType.dinner);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
