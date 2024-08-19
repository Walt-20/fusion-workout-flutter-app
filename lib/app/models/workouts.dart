class Workout {
  final String exercise;
  final String weight;
  final String repetitions;
  final String sets;

  Workout({
    required this.exercise,
    required this.weight,
    required this.repetitions,
    required this.sets,
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise': exercise,
      'weight': weight,
      'repetitions': repetitions,
      'sets': sets,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      exercise: map['exercise'],
      weight: map['weight'],
      repetitions: map['repetitions'],
      sets: map['sets'],
    );
  }
}
