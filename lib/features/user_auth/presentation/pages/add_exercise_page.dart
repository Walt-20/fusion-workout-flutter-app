import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/pages/search_exercise_page.dart';

class AddExercisePage extends StatefulWidget {
  final String? exerciseMuscle;
  final String? exerciseName;

  const AddExercisePage({
    super.key,
    this.exerciseMuscle,
    this.exerciseName,
  });

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _muscleController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.exerciseMuscle != null) {
      _muscleController.text = widget.exerciseMuscle!;
      _nameController.text = widget.exerciseName!;
    }
  }

  @override
  void dispose() {
    _muscleController.dispose();
    _nameController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _exerciseForm() {
    final name = _nameController.text;
    final muscle = _muscleController.text;
    final reps = _repsController.text;
    final sets = _setsController.text;
    final weight = _weightController.text;

    if (name.isNotEmpty &&
        muscle.isNotEmpty &&
        reps.isNotEmpty &&
        sets.isNotEmpty &&
        weight.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Exercise Added'),
            content: Text(
                'Name: $name\nMuscle: $muscle\nReps: $reps\nSets: $sets\nWeight: $weight'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchExercisePage()),
                  );
                },
                child: Text("Alright"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Exercise'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Exercise Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the exercise name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _muscleController,
                decoration: InputDecoration(labelText: 'Muscle Group'),
              ),
              TextFormField(
                controller: _repsController,
                decoration: InputDecoration(labelText: 'Repititions'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _setsController,
                decoration: InputDecoration(labelText: 'Sets'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _exerciseForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
