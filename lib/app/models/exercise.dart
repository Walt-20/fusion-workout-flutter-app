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
  List<ExerciseSet>? sets;
  bool? completed;
  String? uid;

  Exercise({
    required this.name,
    this.type = '',
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    List<ExerciseSet>? sets,
    this.completed = false,
    this.uid,
  }) : sets = sets ?? [];

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

  factory Exercise.fromFirebaseJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      muscle: json['muscle'] ?? '',
      equipment: json['equipment'] ?? '',
      difficulty: json['difficulty'] ?? '',
      instructions: json['instructions'] ?? '',
      sets: (json['sets'] as List<dynamic>?)
              ?.map((set) => ExerciseSet.fromJson(set as Map<String, dynamic>))
              .toList() ??
          [],
      completed: json['completed'] ?? false,
      uid: json['uid'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'muscle': muscle,
      'equipment': equipment,
      'difficulty': difficulty,
      'instructions': instructions,
      'sets': sets!.map((set) => set.toJson()).toList(),
      'completed': completed,
      'uid': uid,
    };
  }
}

class ExerciseSet {
  int reps;
  double weight;
  bool isDone;

  ExerciseSet({required this.reps, required this.weight, required this.isDone});

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      reps: json['reps'] as int,
      weight: json['weight'] as double,
      isDone: json['isDone'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'isDone': isDone,
    };
  }
}
