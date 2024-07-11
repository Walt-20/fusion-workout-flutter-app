import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/event.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/workouts.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/workout_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Event>> workouts = {};
  DateTime? _selectedDay;
  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _fetchEventsFromFirestore();
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _focusedDay = day;
      _selectedDay = day;
      _selectedEvents.value = _getEventsForDay(day);
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return workouts[day] ?? [];
  }

  void _showAddEventDialog() {
    final _eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Event"),
          content: TextField(
            controller: _eventController,
            decoration: InputDecoration(labelText: "Event Name"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final eventName = _eventController.text;
                if (eventName.isNotEmpty) {
                  final event = Event(name: eventName, workouts: []);
                  setState(() {
                    workouts[_selectedDay!] = (workouts[_selectedDay!] ?? [])
                      ..add(event);
                    _selectedEvents.value = _getEventsForDay(_selectedDay!);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text("Create Event"),
            ),
          ],
        );
      },
    );
  }

  void _showEditEventDialog(Event event) {
    final _eventController = TextEditingController(text: event.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Event"),
          content: TextField(
            controller: _eventController,
            decoration: InputDecoration(labelText: "Event Name"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final newName = _eventController.text;
                if (newName.isNotEmpty) {
                  setState(() {
                    event.name = newName;
                    _selectedEvents.value = _getEventsForDay(_selectedDay!);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showAddWorkoutDialog(Event event) async {
    final workout = await showDialog<Workout>(
      context: context,
      builder: (BuildContext context) {
        return AddWorkoutDialog(event.name);
      },
    );

    if (workout != null) {
      setState(() {
        event.workouts.add(workout);
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    }
  }

  void _showEditWorkoutDialog(Event event, Workout workout) {
    final _exerciseController = TextEditingController(text: workout.exercise);
    final _weightController = TextEditingController(text: workout.weight.toString());
    final _repsController = TextEditingController(text: workout.repetitions.toString());
    final _setsController = TextEditingController(text: workout.sets.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Workout"),
          content: Column(
            children: [
              TextField(
                controller: _exerciseController,
                decoration: InputDecoration(labelText: "Exercise"),
              ),
              TextField(
                controller: _weightController,
                decoration: InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _repsController,
                decoration: InputDecoration(labelText: "Repetitions"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _setsController,
                decoration: InputDecoration(labelText: "Sets"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final updatedWorkout = Workout(
                  exercise: _exerciseController.text,
                  weight: _weightController.text,
                  repetitions: _repsController.text,
                  sets: _setsController.text,
                );

                setState(() {
                  final index = event.workouts.indexOf(workout);
                  if (index != -1) {
                    event.workouts[index] = updatedWorkout;
                    _selectedEvents.value = _getEventsForDay(_selectedDay!);
                  }
                  Navigator.of(context).pop();
                });
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(Event event) {
    setState(() {
      workouts[_selectedDay!]?.remove(event);
      if (workouts[_selectedDay!]?.isEmpty ?? false) {
        workouts.remove(_selectedDay!);
      }

      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  void _deleteWorkout(Event event, Workout workout) {
    setState(() {
      event.workouts.remove(workout);
      if (event.workouts.isEmpty) {
        workouts[_selectedDay!]!.remove(event);
        if (workouts[_selectedDay!]!.isEmpty) {
          workouts.remove(_selectedDay!);
        }
      }
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  Future<void> _fetchEventsFromFirestore() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final userEventsCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('events');

    try {
      final snapshot = await userEventsCollection.get();
      final Map<DateTime, List<Event>> fetchedEvents = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = DateTime.parse(doc.id);
        final eventName = data['name'] as String;
        final workoutsData = data['workouts'] as List<dynamic>? ?? [];

        // Parse workouts
        final workouts = workoutsData.map((w) {
          final workoutData = w as Map<String, dynamic>;
          return Workout(
            exercise: workoutData['exercise'] ?? '',
            weight: workoutData['weight'] ?? 0,
            repetitions: workoutData['repetitions'] ?? 0,
            sets: workoutData['sets'] ?? 0,
          );
        }).toList();

        final event = Event(
          name: eventName,
          workouts: workouts,
        );

        if (fetchedEvents.containsKey(date)) {
          fetchedEvents[date]!.add(event);
        } else {
          fetchedEvents[date] = [event];
        }
      }

      setState(() {
        workouts = fetchedEvents;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    } catch (e) {
      const AlertDialog(
        title: Text("Error"),
        content: Text("Failed to fetch events"),
      );
    }
  }

  Future<void> _saveEventToDatabase(Map<DateTime, List<Event>> events) async {
    String user = FirebaseAuth.instance.currentUser!.uid;
    try {
      final FirebaseAuthService _firestore = FirebaseAuthService();
      await _firestore.writeEventToFirestore(user, events);
    } catch (e) {
      const AlertDialog(
        title: Text("Error"),
        content: Text("Error savings events"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workouts"),
        backgroundColor: const Color.fromARGB(255, 85, 85, 85),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveEventToDatabase(workouts);
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Today " + _focusedDay.toString().split(" ")[0]),
            TableCalendar(
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, _focusedDay),
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay,
            ),
            SizedBox(height: 8.0),
            SizedBox(
              height: 300,
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, events, _) {
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with event name and action icons
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.name,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () => _showEditEventDialog(event),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () => _showAddWorkoutDialog(event),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => _deleteEvent(event),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            // Workouts list
                            Column(
                              children: event.workouts.map((w) {
                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                                  title: Text(
                                      '${w.exercise} (${w.weight} kg, ${w.repetitions} reps, ${w.sets} sets)'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () => _showEditWorkoutDialog(event, w),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => _deleteWorkout(event, w),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
