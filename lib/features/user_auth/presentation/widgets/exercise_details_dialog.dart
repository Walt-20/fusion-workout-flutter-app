import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/exercise.dart';

class ExerciseDetailsDialog extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailsDialog({
    required this.exercise,
    super.key,
  });

  @override
  State<ExerciseDetailsDialog> createState() => _ExerciseDetailsDialogState();
}

class _ExerciseDetailsDialogState extends State<ExerciseDetailsDialog> {
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _repsController.dispose();
    _setsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Details for ${widget.exercise.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _repsController,
            decoration: const InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _setsController,
            decoration: const InputDecoration(labelText: 'Sets'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Weight'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final reps = int.tryParse(_repsController.text) ?? 0;
            final sets = int.tryParse(_setsController.text) ?? 0;
            final weight = double.tryParse(_weightController.text) ?? 0.0;

            if (reps > 0 && sets > 0 && weight > 0) {
              Navigator.of(context).pop({
                'exercise': widget.exercise,
                'reps': reps,
                'sets': sets,
                'weight': weight,
              });
            } else {
              // Handle validation or show an error message
            }
          },
          child: const Text('Update'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
