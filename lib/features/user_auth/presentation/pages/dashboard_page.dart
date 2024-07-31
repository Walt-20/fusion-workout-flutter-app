import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/exercise.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/search_exercise_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/calorie_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/exercise_details_dialog.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  final user = FirebaseAuth.instance.currentUser!;
  FirebaseAuthService _auth = FirebaseAuthService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> exercises = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchExercisesFromDatabase();
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
    }
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
                        _fetchExercisesFromDatabase();
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
      'name': exercise.name,
      'muscle': exercise.muscle,
      'reps': exercise.reps,
      'sets': exercise.sets,
      'weight': exercise.weight,
    };
    await _auth.updateExerciseInFirebase(_focusedDay, [exerciseMap]);
    await _fetchExercisesFromDatabase();
  }

  Future<void> _fetchExercisesFromDatabase() async {
    try {
      final fetchedExercises = await _auth.fetchExercises(_focusedDay);
      setState(() {
        exercises = fetchedExercises;
      });
    } catch (e) {
      debugPrint("Error fetching exercises: $e");
    }
  }

  void _updateDashboard() {
    setState(() {
      _fetchExercisesFromDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(237, 255, 134, 21),
              ),
              child: Text(
                'Fusion Workout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              key: const Key('homeButton'),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardPage()),
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
                    builder: (context) => const CalorieTrackingPage(),
                  ),
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
                height: MediaQuery.of(context).size.height * 0.25,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (exercises.isNotEmpty)
                      Expanded(
                        child: SingleChildScrollView(
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
                                            exercise: updateExercise);
                                      },
                                    );

                                    if (result != null) {
                                      setState(() {
                                        final updatedExercise = Exercise(
                                          name: exercise['name'],
                                          muscle: exercise['muscle'],
                                          equipment:
                                              exercise['equipment'] ?? '',
                                          difficulty:
                                              exercise['difficulty'] ?? '',
                                          instructions:
                                              exercise['instructions'] ?? '',
                                          reps: result['reps'],
                                          sets: result['sets'],
                                          weight: result['weight'],
                                          type: '',
                                        );

                                        _updateExerciseInDatabase(
                                            updatedExercise);
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    height: MediaQuery.of(context).size.height *
                                        0.25,
                                    margin: const EdgeInsets.only(right: 8.0),
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
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
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          exercise['muscle'] ?? 'No Muscle',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "Reps: ${exercise['reps'].toString()}" ??
                                              'Reps: ',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "Sets: ${exercise['sets'].toString()}" ??
                                              'Sets: ',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "Weight: ${exercise['weight'].toString()}" ??
                                              'Weight: ',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              // Add button at the end of the list
                              Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: Icon(Icons.add),
                                  iconSize: 32.0,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SearchExercisePage(
                                          selectedDate:
                                              _selectedDay ?? DateTime.now(),
                                          onExerciseAdded: _updateDashboard,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Add Workout",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(
                                width:
                                    16.0, // Adds spacing between the text and the icon
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                iconSize: 32.0,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchExercisePage(
                                        selectedDate:
                                            _selectedDay ?? DateTime.now(),
                                        onExerciseAdded:
                                            _fetchExercisesFromDatabase,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.25,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add Meal",
                      style: TextStyle(
                        fontSize: 24.0,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      iconSize: 32.0,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
