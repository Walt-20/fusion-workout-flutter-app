import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fusion_workouts/app/pages/profile_page.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/app/models/exercise.dart';
import 'package:fusion_workouts/app/models/food.dart';
import 'package:fusion_workouts/app/models/food_database.dart';
import 'package:fusion_workouts/app/pages/search_exercise_page.dart';
import 'package:fusion_workouts/app/pages/search_food_page.dart';
import 'package:fusion_workouts/app/widgets/exercise_details_dialog.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseAuthService _auth = FirebaseAuthService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> exercises = [];
  Map<String, List<FoodForDatabase>> nutritionalData = {};
  Map<String, List<Food>> foodData = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchExercisesFromDatabase();
    _fetchNutritionalDataFromDatabase();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      await _fetchExercisesFromDatabase();
      await _fetchNutritionalDataFromDatabase();
    }
  }

  void _clearLocalDatastructures() {
    exercises = [];
    nutritionalData = {};
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Day"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: TableCalendar(
                  availableGestures: AvailableGestures.all,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2020, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setDialogState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setDialogState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    setDialogState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Color.fromARGB(237, 255, 134, 21),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color.fromARGB(237, 255, 134, 21),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Colors.red),
                    outsideTextStyle: TextStyle(color: Colors.grey),
                    outsideDaysVisible: false,
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_selectedDay != null) {
                      setState(() {
                        _focusedDay = _selectedDay!;
                        _clearLocalDatastructures();
                        _fetchExercisesFromDatabase();
                        _fetchNutritionalDataFromDatabase();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(237, 255, 134, 21),
                    shadowColor: Colors.black,
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateExerciseInDatabase(Exercise exercise) async {
    Map<String, dynamic> exerciseMap = {
      'id': exercise.uid,
      'name': exercise.name,
      'muscle': exercise.muscle,
      'reps': exercise.reps,
      'sets': exercise.sets,
      'weight': exercise.weight,
      'completed': exercise.completed,
    };
    await _auth.updateExerciseInFirebase(_focusedDay, exerciseMap);
    await _fetchExercisesFromDatabase();
  }

  Future<void> _fetchNutritionalDataFromDatabase() async {
    try {
      final fetchedNutrition = await _auth.fetchNutritionalData(_focusedDay);
      setState(() {
        nutritionalData = fetchedNutrition;
      });
    } catch (e) {
      debugPrint("issues require tissues");
    }
  }

  Future<void> _fetchExercisesFromDatabase() async {
    try {
      final fetchedExercises = await _auth.fetchExercises(_focusedDay);
      if (fetchedExercises.isNotEmpty) {
        setState(() {
          exercises = fetchedExercises;
        });
      }
    } catch (e) {
      debugPrint("Error fetching exercises: $e");
    }
  }

  void _updateDashboard() {
    setState(() {
      _fetchExercisesFromDatabase();
    });
  }

  Future<void> _removeFromDatabase(String uid) async {
    await _auth.removeExerciseFromFirebase(_focusedDay, uid);
  }

  Future<void> _moveCheckedExerciseToEndOfList(Exercise exercise) async {
    Map<String, dynamic> exerciseMap = {
      'id': exercise.uid,
      'name': exercise.name,
      'muscle': exercise.muscle,
      'reps': exercise.reps,
      'sets': exercise.sets,
      'weight': exercise.weight,
      'completed': exercise.completed,
    };

    await _auth.updateMoveExerciseInFirebase(_focusedDay, [exerciseMap]);
  }

  num calculateTotalCalories(
      Map<String, List<FoodForDatabase>> nutritionalData) {
    num totalCalories = 0;

    // ignore: unnecessary_set_literal
    nutritionalData.forEach((key, value) {
      for (var food in value) {
        totalCalories += num.parse(food.totalCalories);
      }
    });

    return totalCalories;
  }

  num calculateTotalProtein(
      Map<String, List<FoodForDatabase>> nutritionalData) {
    num totalProtein = 0;

    nutritionalData.forEach((key, value) {
      for (var food in value) {
        totalProtein += num.parse(food.totalProtein);
      }
    });
    return totalProtein;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchExercisePage(
              selectedDate: _selectedDay ?? DateTime.now(),
              onExerciseAdded: _updateDashboard,
            ),
          ),
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchFoodPage(
                selectedDate: _selectedDay ?? DateTime.now(),
                onFoodAdded: _fetchNutritionalDataFromDatabase),
          ),
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Color.fromARGB(237, 255, 134, 21),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.fitness_center,
              color: Color.fromARGB(237, 255, 134, 21),
            ),
            label: "Exercise",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_dining,
              color: Color.fromARGB(237, 255, 134, 21),
            ),
            label: "Nutrition",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Color.fromARGB(237, 255, 134, 21),
            ),
            label: "Profile",
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(237, 255, 134, 21),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _showCalendarDialog,
                child: Container(
                  width: double.infinity,
                  color: const Color.fromARGB(237, 255, 134, 21),
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      _selectedDay == null ||
                              isSameDay(_selectedDay!, DateTime.now())
                          ? "Today: ${DateFormat('EEE M/d/y').format(DateTime.now())}"
                          : DateFormat('EEE M/d/y').format(_selectedDay!),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.35,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: exercises.isNotEmpty
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Display existing exercises
                            ...exercises.map((exercise) {
                              return GestureDetector(
                                onTap: () async {
                                  final updateExercise =
                                      Exercise.fromJson(exercise);

                                  final result =
                                      await showDialog<Map<String, dynamic>?>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ExerciseDetailsDialog(
                                        exercise: updateExercise,
                                      );
                                    },
                                  );

                                  if (result != null) {
                                    final updatedExercise = Exercise(
                                      uid: exercise['id'],
                                      name: exercise['name'],
                                      muscle: exercise['muscle'],
                                      equipment: exercise['equipment'] ?? '',
                                      difficulty: exercise['difficulty'] ?? '',
                                      instructions:
                                          exercise['instructions'] ?? '',
                                      reps: result['reps'],
                                      sets: result['sets'],
                                      weight: result['weight'],
                                      type: '',
                                      completed: false,
                                    );

                                    _updateExerciseInDatabase(updatedExercise);
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.35,
                                  margin: const EdgeInsets.only(right: 8.0),
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8.0),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise['name'] ?? 'No Name',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: exercise['completed'] == true
                                              ? Colors.grey[600]
                                              : const Color.fromARGB(
                                                  237, 255, 134, 21),
                                          decoration:
                                              exercise['completed'] == true
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        exercise['muscle'] ?? 'No Muscle',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: exercise['completed'] == true
                                              ? Colors.grey[500]
                                              : Colors.grey[600],
                                          decoration:
                                              exercise['completed'] == true
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        "Reps: ${exercise['reps']?.join(',') ?? 'Add reps'}",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: exercise['completed'] == true
                                              ? Colors.grey[500]
                                              : Colors.grey[600],
                                          decoration:
                                              exercise['completed'] == true
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        "Sets: ${exercise['sets']?.toString() ?? 'Add sets'}",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: exercise['completed'] == true
                                              ? Colors.grey[500]
                                              : Colors.grey[600],
                                          decoration:
                                              exercise['completed'] == true
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        "Weight: ${exercise['weight']?.join(',') ?? 'Add weights'}",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: exercise['completed'] == true
                                              ? Colors.grey[500]
                                              : Colors.grey[600],
                                          decoration:
                                              exercise['completed'] == true
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                        ),
                                      ),
                                      const Spacer(),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: SizedBox(
                                          width: 120,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons
                                                    .remove_circle_outline),
                                                onPressed: () async {
                                                  await _removeFromDatabase(
                                                      exercise['id']);
                                                  exercises.removeWhere(
                                                      (item) =>
                                                          item['id'] ==
                                                          exercise['id']);
                                                  setState(() {});
                                                },
                                              ),
                                              Checkbox(
                                                fillColor: WidgetStateProperty
                                                    .resolveWith(
                                                        (Set<WidgetState>
                                                            states) {
                                                  if (states.contains(
                                                      WidgetState.selected)) {
                                                    return const Color.fromARGB(
                                                        237, 255, 134, 21);
                                                  }
                                                  return Colors.white;
                                                }),
                                                value: exercise['completed'] ??
                                                    false,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    exercise['completed'] =
                                                        value ?? false;
                                                    if (exercise['completed']) {
                                                      exercises.removeWhere(
                                                          (item) =>
                                                              item['name'] ==
                                                              exercise['name']);
                                                      exercises.add(exercise);
                                                    }
                                                    final updatedExercise =
                                                        Exercise(
                                                      uid: exercise['id'],
                                                      name: exercise['name'],
                                                      muscle:
                                                          exercise['muscle'],
                                                      equipment: exercise[
                                                              'equipment'] ??
                                                          '',
                                                      difficulty: exercise[
                                                              'difficulty'] ??
                                                          '',
                                                      instructions: exercise[
                                                              'instructions'] ??
                                                          '',
                                                      reps: exercise['reps'],
                                                      sets: exercise['sets'],
                                                      weight:
                                                          exercise['weight'],
                                                      type: '',
                                                      completed:
                                                          exercise['completed'],
                                                    );
                                                    _moveCheckedExerciseToEndOfList(
                                                        updatedExercise);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                            Container(
                              margin: const EdgeInsets.only(right: 8.0),
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text(
                          "Add Workout",
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16.0),
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.35,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Calories: ${calculateTotalCalories(nutritionalData)} kcal",
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Protein: ${calculateTotalProtein(nutritionalData)} g",
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 32.0,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    launchUrl(
                      Uri.parse('https://www.fatsecret.com'),
                    );
                  },
                  child: SvgPicture.network(
                    'https://platform.fatsecret.com/api/static/images/powered_by_fatsecret.svg',
                    height: 50,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
