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
    sets = widget.exercise.sets ?? [];
    isChecked = List<bool>.filled(sets.length, false, growable: true);
  }

  void _addSetToFirestore(Exercise exercise) async {
    debugPrint("The exercise UID is ${exercise.uid}");
    debugPrint("Exercise completed is ${exercise.completed}");
    Map<String, dynamic> exerciseMap = exercise.toJson();
    debugPrint("what is exercise map? ${exerciseMap.toString()}");
    await _auth.updateSetsInDatabase(widget.selectedDate, exerciseMap);
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
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(237, 255, 134, 21),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(237, 255, 134, 21),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(237, 255, 134, 21),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: sets[index].reps.toString(),
                    cursorColor: const Color.fromARGB(237, 255, 134, 21),
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
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(237, 255, 134, 21),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(237, 255, 134, 21),
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(237, 255, 134, 21),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: sets[index].weight.toString(),
                    cursorColor: Color.fromARGB(237, 255, 134, 21),
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
                      _addSetToFirestore(widget.exercise);
                    });
                  },
                  icon: Icon(Icons.delete),
                ),
                Checkbox(
                  value: sets[index].isDone,
                  activeColor: Color.fromARGB(237, 255, 134, 21),
                  onChanged: (bool? value) {
                    setState(() {
                      sets[index].isDone = value ?? false;
                      _addSetToFirestore(widget.exercise);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(237, 255, 134, 21),
        onPressed: () {
          setState(() {
            sets.add(ExerciseSet(reps: 0, weight: 0.0, isDone: false));
            isChecked.add(false);
            widget.exercise.sets = sets;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
