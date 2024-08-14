import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/workouts.dart';

class AddWorkoutDialog extends StatefulWidget {
  final String eventName;

  const AddWorkoutDialog(this.eventName, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddWorkoutDialogState createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<AddWorkoutDialog> {
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Workout to ${widget.eventName}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            key: const Key('exerciseNameField'),
            controller: _exerciseController,
            decoration: const InputDecoration(labelText: "Exercise"),
          ),
          TextField(
            key: const Key('weightField'),
            controller: _weightController,
            decoration: const InputDecoration(labelText: "Weight"),
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('repsField'),
                  controller: _repetitionsController,
                  decoration: const InputDecoration(labelText: "Reps"),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const Key('setsField'),
                  controller: _setsController,
                  decoration: const InputDecoration(labelText: "Sets"),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          key: const Key('addWorkoutButton'),
          onPressed: () {
            final workout = Workout(
              exercise: _exerciseController.text,
              weight: _weightController.text,
              repetitions: _repetitionsController.text,
              sets: _setsController.text,
            );
            Navigator.of(context).pop(workout);
          },
          child: const Text("Add Workout"),
        ),
      ],
    );
  }
}
