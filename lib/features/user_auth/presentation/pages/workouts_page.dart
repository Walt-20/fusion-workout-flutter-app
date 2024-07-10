import 'package:flutter/material.dart';
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
      // If the event has no more workouts, you might want to remove the event as well,
      // or you can keep it based on your application's requirements.
      if (event.workouts.isEmpty) {
        workouts[_selectedDay!]!.remove(event);
        if (workouts[_selectedDay!]!.isEmpty) {
          workouts.remove(_selectedDay!);
        }
      }
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workouts"),
        backgroundColor: const Color.fromARGB(255, 85, 85, 85),
        iconTheme: const IconThemeData(color: Colors.white),
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
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(event.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: event.workouts
                                .map((w) => ListTile(
                                  title: Text(
                                      '${w.exercise} (${w.weight} kg, ${w.repetitions} reps, ${w.sets} sets)'),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => _deleteWorkout(event, w),
                                      ),
                                )).toList(),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
