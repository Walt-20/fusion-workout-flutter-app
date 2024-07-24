import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';

import 'package:fusion_workouts/features/user_auth/presentation/pages/dashboard_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/workouts_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/add_food_dialog.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/meal_summary.dart';
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
  DateTime _selectedDay = DateTime.now();
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
  List<Food> meals = [];
  Map<String, List<Food>> mealsByDate = {};
  MealType _selectedMealType = MealType.breakfast;

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _focusedDay = day;
      _selectedDay = day;

      if (mealsByDate.isEmpty) {
        totalBreakfastCalories = 0;
        totalBreakfastProtein = 0;
        totalBreakfastCarbs = 0;
        totalBreakfastFats = 0;
        totalLunchCalories = 0;
        totalLunchProtein = 0;
        totalLunchCarbs = 0;
        totalLunchFats = 0;
        totalDinnerCalories = 0;
        totalDinnerCarbs = 0;
        totalDinnerProtein = 0;
        totalDinnerFats = 0;
      } else {
        // calculate the meals
        _calculateTotals(_selectedDay, _selectedMealType);
      }
    });

    Navigator.pop(context);
  }

  void _addViaFoodWidgetDialog(MealType mealType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddFoodDialog(
          mealType: _selectedMealType,
          updateNutritionalValues: (
            double newTotalCalories,
            double newTotalProtein,
            double newTotalCarbs,
            double newTotalFats,
            Food updatedFood,
            int servings,
          ) {
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

              String selectedDay =
                  DateFormat('yyyy-MM-dd').format(_selectedDay!);

              // Assign the selected day to the updated food item
              if (_selectedDay != null) {
                updatedFood.day = selectedDay;
              }

              // Add or update the meals list for the selected day
              if (mealsByDate.containsKey(selectedDay)) {
                mealsByDate[selectedDay]!.add(updatedFood);
              } else {
                mealsByDate[selectedDay] = [updatedFood];
              }

              // Recalculate totals based on the selected meal type
              _calculateTotals(_selectedDay!, mealType);
            });
          },
        );
      },
    );
  }

  void _calculateTotals(DateTime selectedDay, MealType mealType) {
    // Reset totals before calculating
    totalBreakfastCalories = 0;
    totalBreakfastProtein = 0;
    totalBreakfastCarbs = 0;
    totalBreakfastFats = 0;
    totalLunchCalories = 0;
    totalLunchProtein = 0;
    totalLunchCarbs = 0;
    totalLunchFats = 0;
    totalDinnerCalories = 0;
    totalDinnerProtein = 0;
    totalDinnerCarbs = 0;
    totalDinnerFats = 0;

    // Format selected day to yyyy-MM-dd format
    String selectedDayFormatted = DateFormat('yyyy-MM-dd').format(selectedDay);

    // Fetch meals for the selected day from mealsByDate map
    List<Food>? filteredMeals = mealsByDate[selectedDayFormatted];

    // Calculate totals based on the meal type
    if (filteredMeals != null) {
      for (var meal in filteredMeals) {
        switch (mealType) {
          case MealType.breakfast:
            totalBreakfastCalories += meal.calories * meal.servings;
            totalBreakfastProtein += meal.protein * meal.servings;
            totalBreakfastCarbs += meal.carbs * meal.servings;
            totalBreakfastFats += meal.fats * meal.servings;
            break;
          case MealType.lunch:
            totalLunchCalories += meal.calories * meal.servings;
            totalLunchProtein += meal.protein * meal.servings;
            totalLunchCarbs += meal.carbs * meal.servings;
            totalLunchFats += meal.fats * meal.servings;
            break;
          case MealType.dinner:
            totalDinnerCalories += meal.calories * meal.servings;
            totalDinnerProtein += meal.protein * meal.servings;
            totalDinnerCarbs += meal.carbs * meal.servings;
            totalDinnerFats += meal.fats * meal.servings;
            break;
          default:
            debugPrint("Error: Invalid meal type");
            break;
        }
      }
    }

    // Force the UI to update after calculating totals
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Get formatted selected day
    String selectedDayFormatted = DateFormat('yyyy-MM-dd').format(_selectedDay);

    // Filter meals for the selected day
    List<Food>? filteredMeals = mealsByDate[selectedDayFormatted];

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
                key: Key('breakfast mealsummarywidget'),
                meals: filteredMeals ?? [],
                mealName: 'Breakfast',
                totalCalories: totalBreakfastCalories,
                proteinIntake: totalBreakfastProtein,
                carbIntake: totalBreakfastCarbs,
                fatIntake: totalBreakfastFats,
                onTap: () {
                  setState(() {
                    _selectedMealType = MealType.breakfast;
                  });
                  _addViaFoodWidgetDialog(_selectedMealType);
                },
                onUpdate: (updatedMeal) {
                  setState(() {
                    _calculateTotals(_selectedDay!, _selectedMealType);
                  });
                },
              ),
              Padding(padding: padding),
              MealSummaryWidget(
                key: Key('lunch mealsummarywidget'),
                meals: filteredMeals ?? [],
                mealName: 'Lunch',
                totalCalories: totalLunchCalories,
                proteinIntake: totalLunchProtein,
                carbIntake: totalLunchCarbs,
                fatIntake: totalLunchFats,
                onTap: () {
                  setState(() {
                    _selectedMealType = MealType.lunch;
                  });
                  _addViaFoodWidgetDialog(_selectedMealType);
                },
                onUpdate: (updatedMeal) {
                  setState(() {
                    _calculateTotals(_selectedDay!, _selectedMealType);
                  });
                },
              ),
              Padding(padding: padding),
              MealSummaryWidget(
                key: Key('dinner mealsummarywidget'),
                meals: filteredMeals ?? [],
                mealName: 'Dinner',
                totalCalories: totalDinnerCalories,
                proteinIntake: totalDinnerProtein,
                carbIntake: totalDinnerCarbs,
                fatIntake: totalDinnerFats,
                onTap: () {
                  setState(() {
                    _selectedMealType = MealType.dinner;
                  });
                  _addViaFoodWidgetDialog(_selectedMealType);
                },
                onUpdate: (updatedMeal) {
                  setState(() {
                    _calculateTotals(_selectedDay!, _selectedMealType);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
