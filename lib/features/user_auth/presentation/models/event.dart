import 'package:fusion_workouts/features/user_auth/presentation/models/workouts.dart';

class Event {
  String name;
  final List<Workout> workouts;

  Event({
    required this.name,
    this.workouts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'workouts': workouts.map((w) => w.toMap()).toList(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      name: map['name'],
      workouts: (map['workouts'] as List).map((w) => Workout.fromMap(w)).toList(),
    );
  }
}
