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
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load exercises');
      }
    } catch (e) {
      print('Error fetching exercises: $e');
      rethrow; // Rethrow if you want to handle it further up the call stack
    }
  }

  Iterable<Widget> _buildSuggestions(SearchController controller) {
    return [
      FutureBuilder<List<Exercise>>(
        future: _exercises,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No suggestions available'));
          }

          final exercises = snapshot.data!;
          return ListView(
            shrinkWrap: true,
            children: List.generate(exercises.length, (int index) {
              final Exercise item = exercises[index];
              return ListTile(
                title: Text(item.name),
                onTap: () {
                  setState(() {
                    if (!_selectedExercises.contains(item)) {
                      _selectedExercises.add(item);
                    }
                    controller.closeView(item.name);
                  });
                },
              );
            }),
          );
        },
      )
    ];
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
            child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  hintText: "Exercise name, muscle, type, and difficulty",
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  // onTap: () {
                  //   controller.openView();
                  // },
                  // onChanged: (_) {
                  //   controller.openView();
                  // },
                  onSubmitted: (query) {
                    debugPrint("$query submited");
                    _queryAPI(query);
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return _buildSuggestions(controller);
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Color.fromARGB(237, 255, 134, 21),
                        ),
                      ),
                      subtitle: Text(
                        'Muscle: ${exercise.muscle}\n'
                        'Reps: ${exercise.reps ?? ""}\n'
                        'Sets: ${exercise.sets ?? ""}\n'
                        'Weight: ${exercise.weight ?? ""}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
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
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddExercisePage(
                selectedDate: widget.selectedDate,
              );
            },
          );
        },
        tooltip: 'Add Custom Workout',
        child: const Icon(Icons.add),
      ),
    );
  }
}
