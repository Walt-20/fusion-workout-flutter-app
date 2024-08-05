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
    debugPrint(
        "_updateExerciseInDatabase dashboard page, uid is ${exercise.uid}");
    Map<String, dynamic> exerciseMap = {
      'id': exercise.uid,
      'name': exercise.name,
      'muscle': exercise.muscle,
      'reps': exercise.reps,
      'sets': exercise.sets,
      'weight': exercise.weight,
      'completed': exercise.completed,
    };
    debugPrint("Exercise map is: ${exerciseMap.toString()}");
    debugPrint("the id is ${exerciseMap['id']}");
    await _auth.updateExerciseInFirebase(_focusedDay, exerciseMap);
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

  Future<void> _removeFromDatabase(String uid) async {
    debugPrint("the uid is $uid");
    await _auth.removeExerciseFromFirebase(_focusedDay, uid);
  }

  // Future<void> _moveCheckedExerciseToEndOfList(Exercise exercise) async {
  //   Map<String, dynamic> exerciseMap = {
  //     'id': exercise.uid,
  //     'name': exercise.name,
  //     'muscle': exercise.muscle,
  //     'reps': exercise.reps,
  //     'sets': exercise.sets,
  //     'weight': exercise.weight,
  //     'completed': exercise.completed,
  //   };
  //   await _auth.updateExerciseInFirebase(_focusedDay, exerciseMap);

  //   try {
  //     final fetchedExercises = await _auth.fetchExercises(_focusedDay);

  //     List<Map<String, dynamic>> updatedExercises = List.from(fetchedExercises);

  //     updatedExercises.sort((a, b) {
  //       bool aCompleted = a['completed'] ?? false;
  //       bool bCompleted = b['completed'] ?? false;

  //       if (aCompleted && !bCompleted) return 1;
  //       if (!aCompleted && bCompleted) return -1;
  //       return 0;
  //     });

  //     await _auth.updateExerciseInFirebase(_focusedDay, updatedExercises);

  //     setState(() {
  //       exercises = updatedExercises;
  //     });
  //   } catch (e) {
  //     debugPrint("Error updated exercies: $e");
  //   }
  // }

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
                height: MediaQuery.of(context).size.height * 0.35,
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
                                          uid: exercise['id'],
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
                                          completed: false,
                                        );

                                        debugPrint(
                                            'updatedExercise uid: ${updatedExercise.uid}');

                                        _updateExerciseInDatabase(
                                            updatedExercise);
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
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
                                        Text(
                                          exercise['muscle'] ?? 'No Muscle',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: exercise['completed'] == true
                                                ? Colors.grey[500]
                                                : Colors.grey[600],
                                            decoration:
                                                exercise['completed'] == true
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                          ),
                                        ),
                                        Text(
                                          "Reps: ${exercise['reps']?.join(',').toString() ?? "Add reps"}" ??
                                              'Reps: ',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: exercise['completed'] == true
                                                ? Colors.grey[500]
                                                : Colors.grey[600],
                                            decoration:
                                                exercise['completed'] == true
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                          ),
                                        ),
                                        Text(
                                          "Sets: ${exercise['sets']?.toString() ?? "Add sets"}" ??
                                              'Sets: ',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: exercise['completed'] == true
                                                ? Colors.grey[500]
                                                : Colors.grey[600],
                                            decoration:
                                                exercise['completed'] == true
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                          ),
                                        ),
                                        Text(
                                          "Weight: ${exercise['weight']?.join(',').toString() ?? "Add weights"}" ??
                                              'Weight: ',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: exercise['completed'] == true
                                                ? Colors.grey[500]
                                                : Colors.grey[600],
                                            decoration:
                                                exercise['completed'] == true
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                          ),
                                        ),
                                        Spacer(),
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
                                                      return const Color
                                                          .fromARGB(
                                                          237, 255, 134, 21);
                                                    }
                                                    return Colors.white;
                                                  }),
                                                  value:
                                                      exercise['completed'] ??
                                                          false,
                                                  onChanged: (bool? value) {
                                                    setState(
                                                      () {
                                                        debugPrint(
                                                            "exercise is ${exercise['completed']}");
                                                        exercise['completed'] =
                                                            value ?? false;
                                                        debugPrint(
                                                            "exercise is ${exercise['completed']}");

                                                        if (exercise[
                                                            'completed']) {
                                                          exercises.removeWhere(
                                                              (item) =>
                                                                  item[
                                                                      'name'] ==
                                                                  exercise[
                                                                      'name']);
                                                          exercises
                                                              .add(exercise);
                                                        }

                                                        final updatedExercise =
                                                            Exercise(
                                                          name:
                                                              exercise['name'],
                                                          muscle: exercise[
                                                              'muscle'],
                                                          equipment: exercise[
                                                                  'equipment'] ??
                                                              '',
                                                          difficulty: exercise[
                                                                  'difficulty'] ??
                                                              '',
                                                          instructions: exercise[
                                                                  'instructions'] ??
                                                              '',
                                                          reps:
                                                              exercise['reps'],
                                                          sets:
                                                              exercise['sets'],
                                                          weight: exercise[
                                                              'weight'],
                                                          type: '',
                                                          completed: exercise[
                                                              'completed'],
                                                        );

                                                        // _moveCheckedExerciseToEndOfList(
                                                        //     updatedExercise);
                                                      },
                                                    );
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
                              }).toList(),
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
            ],
          ),
        ),
      ),
    );
  }
}
