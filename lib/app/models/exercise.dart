// "name": "Incline Hammer Curls",
//     "type": "strength",
//     "muscle": "biceps",
//     "equipment": "dumbbell",
//     "difficulty": "beginner",
//     "instructions":

class Exercise {
  final String name;
  final String type;
  final String muscle;
  final String equipment;
  final String difficulty;
  final String instructions;
  List<int>? reps;
  List<ExerciseSet>? sets;
  List<double>? weight;
  bool? completed;
  String? uid;

  Exercise({
    required this.name,
    this.type = '',
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    List<int>? reps,
    List<ExerciseSet>? sets,
    List<double>? weight,
    this.completed = false,
    this.uid,
  })  : reps = reps ?? [],
        sets = sets ?? [],
        weight = weight ?? [];

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      muscle: json['muscle'] ?? '',
      equipment: json['equipment'] ?? '',
      difficulty: json['difficulty'] ?? '',
      instructions: json['instructions'] ?? '',
    );
  }

  void updateRepsAndWeight() {
    reps = sets?.map((set) => set.reps).toList();
    weight = sets?.map((set) => set.weight).toList();
  }
}

class ExerciseSet {
  int reps;
  double weight;

  ExerciseSet({required this.reps, required this.weight});

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      reps: json['reps'] as int,
      weight: json['weight'] as double,
    );
  }
}
