import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/workouts.dart';

class AddWorkoutDialog extends StatefulWidget {
  final String eventName;

  AddWorkoutDialog(this.eventName);

  @override
  _AddWorkoutDialogState createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<AddWorkoutDialog> {
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _workoutNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Workout to ${widget.eventName}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            key: Key('exerciseNameField'),
            controller: _exerciseController,
            decoration: InputDecoration(labelText: "Exercise"),
          ),
          TextField(
            key: Key('weightField'),
            controller: _weightController,
            decoration: InputDecoration(labelText: "Weight"),
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: Key('repsField'),
                  controller: _repetitionsController,
                  decoration: InputDecoration(labelText: "Reps"),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: Key('setsField'),
                  controller: _setsController,
                  decoration: InputDecoration(labelText: "Sets"),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          key: Key('add workout'),
          onPressed: () {
            final workout = Workout(
              exercise: _exerciseController.text,
              weight: _weightController.text,
              repetitions: _repetitionsController.text,
              sets: _setsController.text,
            );
            Navigator.of(context).pop(workout);
          },
          child: Text("Add Workout"),
        ),
      ],
    );
  }
}
