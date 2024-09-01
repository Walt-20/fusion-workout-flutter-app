import 'package:flutter/material.dart';
import 'package:fusion_workouts/app/models/exercise.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';

class StartExercisePage extends StatefulWidget {
  final Exercise exercise;
  final DateTime selectedDate;

  const StartExercisePage({
    super.key,
    required this.exercise,
    required this.selectedDate,
  });

  @override
  State<StartExercisePage> createState() => _StartExercisePageState();
}

class _StartExercisePageState extends State<StartExercisePage> {
  List<ExerciseSet> sets = [];
  List<bool> isChecked = [];
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _fetchExerciseData();
  }

  void _addSetToFirestore(Exercise exercise) async {
    debugPrint("The exercise UID is ${exercise.uid}");
    debugPrint("Exercise completed is ${exercise.completed}");
    exercise.updateRepsAndWeight();
    Map<String, dynamic> exerciseMap = {
      'id': exercise.uid,
      'name': exercise.name,
      'muscle': exercise.muscle,
      'reps': exercise.reps,
      'sets': sets.length, // Store the count of sets
      'weight': exercise.weight,
      'completed': exercise.completed,
    };
    await _auth.updateExerciseInFirebase(widget.selectedDate, exerciseMap);
  }

  Future<void> _fetchExerciseData() async {
    try {
      final fetchedExercises = await _auth.fetchExercises(widget.selectedDate);

      final exerciseData = fetchedExercises.firstWhere(
        (exercise) => exercise['id'] == widget.exercise.uid,
        orElse: () => {},
      );

      if (exerciseData != null) {
        setState(() {
          // Initialize reps and weight from the fetched data
          widget.exercise.reps = (exerciseData['reps'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toList() ??
              [];
          widget.exercise.weight = (exerciseData['weight'] as List<dynamic>?)
                  ?.map((e) => e as double)
                  .toList() ??
              [];

          // Initialize sets based on the integer value from Firebase
          int numberOfSets = exerciseData['sets'] as int? ?? 0;
          sets = List.generate(
              numberOfSets, (index) => ExerciseSet(reps: 0, weight: 0.0));
          isChecked = List<bool>.filled(numberOfSets, false, growable: true);
        });
      }
    } catch (e) {
      debugPrint("Error fetching exercise data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: ListView.builder(
        itemCount: sets.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Reps'),
                    keyboardType: TextInputType.number,
                    initialValue: sets[index].reps.toString(),
                    onChanged: (value) {
                      setState(() {
                        sets[index].reps = int.tryParse(value) ?? 0;
                        widget.exercise.sets = sets;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Weight'),
                    keyboardType: TextInputType.number,
                    initialValue: sets[index].weight.toString(),
                    onChanged: (value) {
                      setState(() {
                        sets[index].weight = double.tryParse(value) ?? 0.0;
                        widget.exercise.sets = sets;
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      sets.removeAt(index);
                      isChecked.removeAt(index);
                      widget.exercise.sets = sets;
                    });
                  },
                  icon: Icon(Icons.delete),
                ),
                Checkbox(
                  value: isChecked[index],
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked[index] = value ?? false;
                      if (isChecked[index]) {
                        _addSetToFirestore(widget.exercise);
                      }
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            sets.add(ExerciseSet(reps: 0, weight: 0.0));
            isChecked.add(false);
            widget.exercise.sets = sets;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
