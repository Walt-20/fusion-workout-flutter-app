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
  List<dynamic>? reps;
  int? sets;
  List<dynamic>? weight;
  bool? completed;
  String? uid;

  Exercise({
    required this.name,
    this.type = '',
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    List<dynamic>? reps,
    this.sets,
    List<dynamic>? weight,
    this.completed = false,
    this.uid,
  })  : reps = reps ?? [],
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
}
