import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/exercise.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/add_exercise_page.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/exercise_details_dialog.dart';
import 'package:http/http.dart' as http;

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
  Future<List<Exercise>>? _exercises;
  List<Exercise> _selectedExercises = [];
  Map<String, dynamic> exerciseMap = {};
  FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _fetchExercisesFromDatabase();
  }

  Future<List<Exercise>> fetchSuggestions(String query) async {
    debugPrint("The query is $query");
    try {
      final response = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/exercises?name=$query'),
        headers: {'x-api-key': 'HOsWIdXrBsEI1nCv0p6TWQ==jijyLwr69j7eonaL'},
      );

      debugPrint("The response is ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint("data is ${data.toList()}");
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exercises');
      }
    } catch (e) {
      debugPrint('Error fetching exercises: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load exercises. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
      throw Exception('Failed to load exercies');
    }
  }

  Future<void> _fetchExercisesFromDatabase() async {
    try {
      final fetchedExercises = await _auth.fetchExercises(widget.selectedDate);
      setState(() {
        _selectedExercises = fetchedExercises.map((exerciseMap) {
          return Exercise(
            name: exerciseMap['name'],
            type: exerciseMap['type'] ?? '',
            muscle: exerciseMap['muscle'],
            equipment: exerciseMap['equipment'] ?? '',
            difficulty: exerciseMap['difficulty'] ?? '',
            instructions: exerciseMap['instructions'] ?? '',
            reps: exerciseMap['reps'],
            sets: exerciseMap['sets'],
            weight: exerciseMap['weight'],
            completed: exerciseMap['completed'],
          );
        }).toList();
      });
    } catch (e) {
      debugPrint("Error fetching exercises: $e");
    }
  }

  Future<void> _addToDatabase(Exercise exercise) async {
    Map<String, dynamic> exerciseMap = {
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
    Map<String, dynamic> exerciseMap = {
      'name': exercise.name,
      'muscle': exercise.muscle,
      'reps': exercise.reps,
      'sets': exercise.sets,
      'weight': exercise.weight,
      'completed': exercise.completed,
    };
    await _auth.updateExerciseInFirebase(widget.selectedDate, [exerciseMap]);
    widget.onExerciseAdded();
  }

  Future<void> _removeFromDatabase(
      String name, String muscle, int? reps, int? sets, double? weight) async {
    debugPrint(
        "name $name\nmuscle $muscle\nreps $reps\nsets $sets\nweight $weight");
    await _auth.removeExerciseFromFirebase(
        widget.selectedDate, name, muscle, reps, sets, weight);
    widget.onExerciseAdded();
  }

  Future<void> _queryAPI(String query) async {
    setState(() {
      _exercises = fetchSuggestions(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Exercises')),
      body: Column(
        children: [
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
                                  }
                                  _exercises = Future.value([]);
                                  controller.closeView("");
                                });
                              },
                            );
                          },
                        );
                      }
                    }
                    return const LinearProgressIndicator();
                  },
                )
              ];
            }),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) =>
                    const Divider(height: 8.0),
                itemCount: _selectedExercises.length,
                itemBuilder: (context, index) {
                  _addToDatabase(_selectedExercises[index]);
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
                        setState(() {
                          final updatedExercise = Exercise(
                            name: exercise.name,
                            muscle: exercise.muscle,
                            equipment: exercise.equipment,
                            difficulty: exercise.difficulty,
                            instructions: exercise.instructions,
                            reps: result['reps'],
                            sets: result['sets'],
                            weight: result['weight'],
                            completed: result['completed'],
                            type: '',
                          );

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
                        side: BorderSide(color: Colors.grey[300]!, width: 1.0),
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
                        'Reps: ${exercise.reps ?? ""}\n'
                        'Sets: ${exercise.sets ?? ""}\n'
                        'Weight: ${exercise.weight ?? ""}',
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
                            Checkbox(
                                fillColor: WidgetStateProperty.resolveWith(
                                    (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return const Color.fromARGB(
                                        237, 255, 134, 21);
                                  }
                                  return Colors.white;
                                }),
                                value: exercise.completed,
                                onChanged: (bool? value) {
                                  setState(
                                    () {
                                      debugPrint(
                                          "exercise is ${exercise.completed}");
                                      exercise.completed = value ?? false;
                                      debugPrint(
                                          "exercise is ${exercise.completed}");

                                      if (exercise.completed == true) {
                                        _selectedExercises.removeAt(index);
                                        _selectedExercises.add(exercise);
                                      } else if (exercise.completed == false) {
                                        _selectedExercises.removeAt(index);
                                        _selectedExercises.insert(0, exercise);
                                      }

                                      _updateExerciseInDatabase(exercise);
                                    },
                                  );
                                }),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _removeFromDatabase(
                                    _selectedExercises[index].name,
                                    _selectedExercises[index].muscle,
                                    _selectedExercises[index].reps,
                                    _selectedExercises[index].sets,
                                    _selectedExercises[index].weight,
                                  );
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
        ],
      ),
    );
  }
}
