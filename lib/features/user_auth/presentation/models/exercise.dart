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
  int? reps;
  int? sets;
  double? weight;

  Exercise({
    required this.name,
    required this.type,
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    this.reps,
    this.sets,
    this.weight,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      type: json['type'],
      muscle: json['muscle'],
      equipment: json['equipment'],
      difficulty: json['difficulty'],
      instructions: json['instructions'],
    );
  }
}
