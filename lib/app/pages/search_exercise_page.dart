import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/app/models/exercise.dart';
import 'package:fusion_workouts/app/widgets/exercise_details_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class SearchExercisePage extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onExerciseAdded;

  const SearchExercisePage({
    super.key,
    required this.selectedDate,
    required this.onExerciseAdded,
  });

  @override
  State<SearchExercisePage> createState() => _SearchExercisePageState();
}

class _SearchExercisePageState extends State<SearchExercisePage> {
  List<Exercise> _selectedExercises = [];
  // ignore: prefer_final_fields
  Set<String> _existingExerciseIds = {}; // Track existing exercise IDs
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _fetchExercisesFromDatabase();
  }

  Future<List<Exercise>> fetchSuggestions(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/exercises?name=$query'),
        headers: {'x-api-key': 'HOsWIdXrBsEI1nCv0p6TWQ==jijyLwr69j7eonaL'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exercises');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load exercises. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
      throw Exception('Failed to load exercises');
    }
  }

  Future<void> _fetchExercisesFromDatabase() async {
    try {
      final fetchedExercises = await _auth.fetchExercises(widget.selectedDate);

      setState(() {
        _selectedExercises = fetchedExercises.map((exerciseMap) {
          return Exercise(
            uid: exerciseMap['id'],
            name: exerciseMap['name'],
            muscle: exerciseMap['muscle'],
            equipment: exerciseMap['equipment'] ?? '',
            difficulty: exerciseMap['difficulty'] ?? '',
            instructions: exerciseMap['instructions'] ?? '',
            reps: (exerciseMap['reps'] as List<dynamic>?)
                ?.map((e) => e as int? ?? 0)
                .toList(),
            sets: exerciseMap['sets'],
            weight: (exerciseMap['weight'] as List<dynamic>?)
                ?.map((e) => e as double? ?? 0.0)
                .toList(),
            completed: exerciseMap['completed'],
          );
        }).toList();
      });
    } catch (e) {
      debugPrint("Error fetching exercises: $e");
    }
  }

  Future<void> _addExerciseToFirebase(Exercise exercise) async {
    String uid = const Uuid().v4();
    Map<String, dynamic> exerciseMap = {
      'id': uid,
      'name': exercise.name,
      'muscle': exercise.muscle,
      'reps': exercise.reps,
      'sets': exercise.sets,
      'weight': exercise.weight,
      'completed': exercise.completed,
    };

    await _auth.addExerciseToFirestore(widget.selectedDate, [exerciseMap]);

    widget.onExerciseAdded();
  }

  Future<void> _updateExerciseInDatabase(Exercise exercise) async {
    debugPrint("the exercise uid is ${exercise.uid}");
    debugPrint("exercise completed is ${exercise.completed}");
    Map<String, dynamic> exerciseMap = {
      'id': exercise.uid,
      'name': exercise.name,
      'muscle': exercise.muscle,
      'reps': exercise.reps,
      'sets': exercise.sets,
      'weight': exercise.weight,
      'completed': exercise.completed,
    };
    await _auth.updateExerciseInFirebase(widget.selectedDate, exerciseMap);

    widget.onExerciseAdded();
  }

  Future<void> _removeFromDatabase(String uid) async {
    await _auth.removeExerciseFromFirebase(widget.selectedDate, uid);
    setState(() {
      _existingExerciseIds.remove(uid);
    });
    widget.onExerciseAdded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Exercises')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 8.0),
                  itemCount: _selectedExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _selectedExercises[index];
                    return GestureDetector(
                      onTap: () async {
                        final result = await showDialog<Map<String, dynamic>?>(
                          context: context,
                          builder: (BuildContext context) {
                            return ExerciseDetailsDialog(exercise: exercise);
                          },
                        );

                        if (result != null) {
                          final updatedExercise = Exercise(
                            uid: exercise.uid,
                            name: exercise.name,
                            muscle: exercise.muscle,
                            equipment: exercise.equipment,
                            difficulty: exercise.difficulty,
                            instructions: exercise.instructions,
                            reps: result['reps'],
                            sets: result['sets'],
                            weight: result['weight'],
                            completed: exercise.completed,
                            type: '',
                          );

                          setState(() {
                            debugPrint("the exercise id is ${exercise.uid}");
                            debugPrint(
                                "the exercise completed is ${exercise.completed}");

                            _updateExerciseInDatabase(updatedExercise);

                            _selectedExercises[index] = updatedExercise;
                          });
                        }
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side:
                              BorderSide(color: Colors.grey[300]!, width: 1.0),
                        ),
                        title: Text(
                          exercise.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: exercise.completed == true
                                ? Colors.grey[600]
                                : const Color.fromARGB(237, 255, 134, 21),
                            decoration: exercise.completed == true
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          'Muscle: ${exercise.muscle}\n'
                          'Reps: ${exercise.reps?.join(',') ?? "Click to add reps"}\n'
                          'Sets: ${exercise.sets ?? "Click to add sets"}\n'
                          'Weight: ${exercise.weight?.join(',') ?? "Click to add weights"}',
                          style: TextStyle(
                            color: exercise.completed == true
                                ? Colors.grey[500]
                                : Colors.grey[600],
                            decoration: exercise.completed == true
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: SizedBox(
                          width: 120,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    _removeFromDatabase(
                                        _selectedExercises[index].uid!);
                                    _selectedExercises.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchAnchor.bar(suggestionsBuilder: (context, controller) {
              final searchFuture = fetchSuggestions(controller.text);
              return [
                FutureBuilder(
                  future: searchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final list = snapshot.data;
                      if (list != null) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(list[index].name),
                              onTap: () {
                                setState(() {
                                  if (!_selectedExercises
                                      .contains(list[index])) {
                                    _selectedExercises.insert(0, list[index]);
                                    _addExerciseToFirebase(list[index]);
                                  }
                                  controller.closeView("");
                                });
                              },
                            );
                          },
                        );
                      }
                    }
                    return const LinearProgressIndicator(
                      color: Color.fromARGB(237, 255, 134, 21),
                    );
                  },
                )
              ];
            }),
          ),
        ],
      ),
    );
  }
}
