import 'package:flutter/material.dart';
import 'package:fusion_workouts/app/models/exercise.dart';

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
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _differentRepsController =
      TextEditingController();
  final TextEditingController _differentWeightsController =
      TextEditingController();

  bool _sameRepsForAllSets = true; // Default option
  bool _sameWeightsForAllSets = true; // Default option

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _differentRepsController.dispose();
    _differentWeightsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Details for ${widget.exercise.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Number of sets
            TextField(
              controller: _setsController,
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            // Toggle for same/different reps
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Same reps for all sets'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: _sameRepsForAllSets,
                      onChanged: (value) {
                        setState(() {
                          _sameRepsForAllSets = value ?? true;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Different reps for each set'),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: _sameRepsForAllSets,
                      onChanged: (value) {
                        setState(() {
                          _sameRepsForAllSets = value ?? false;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Reps field
            if (_sameRepsForAllSets)
              TextField(
                controller: _repsController,
                decoration: const InputDecoration(labelText: 'Reps per set'),
                keyboardType: TextInputType.number,
              )
            else
              TextField(
                controller: _differentRepsController,
                decoration: const InputDecoration(
                    labelText: 'Reps per set (comma separated)'),
                keyboardType: TextInputType.text,
              ),
            const SizedBox(height: 10),
            // Toggle for same/different weights
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Same weight for all sets'),
                    leading: Radio<bool>(
                      value: true,
                      groupValue: _sameWeightsForAllSets,
                      onChanged: (value) {
                        setState(() {
                          _sameWeightsForAllSets = value ?? true;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Different weights for each set'),
                    leading: Radio<bool>(
                      value: false,
                      groupValue: _sameWeightsForAllSets,
                      onChanged: (value) {
                        setState(() {
                          _sameWeightsForAllSets = value ?? false;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Weight field
            if (_sameWeightsForAllSets)
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight per set'),
                keyboardType: TextInputType.number,
              )
            else
              TextField(
                controller: _differentWeightsController,
                decoration: const InputDecoration(
                    labelText: 'Weight per set (comma separated)'),
                keyboardType: TextInputType.text,
              ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final sets = int.tryParse(_setsController.text) ?? 0;

            if (sets > 0) {
              List<int>? reps;
              if (_sameRepsForAllSets) {
                final repsValue = int.tryParse(_repsController.text);
                reps = repsValue != null
                    ? List.generate(sets, (index) => repsValue)
                    : null;
              } else {
                final repsList = _differentRepsController.text
                    .split(',')
                    .map(int.tryParse)
                    .toList();
                if (repsList.length == sets &&
                    repsList.every((r) => r != null)) {
                  reps = repsList.cast<int>();
                }
              }

              List<double>? weights;
              if (_sameWeightsForAllSets) {
                final weightValue = double.tryParse(_weightController.text);
                weights = weightValue != null
                    ? List.generate(sets, (index) => weightValue)
                    : null;
              } else {
                final weightsList = _differentWeightsController.text
                    .split(',')
                    .map(double.tryParse)
                    .toList();
                if (weightsList.length == sets &&
                    weightsList.every((w) => w != null)) {
                  weights = weightsList.cast<double>();
                }
              }

              debugPrint(reps.toString());

              if (reps != null && weights != null) {
                Navigator.of(context).pop({
                  'exercise': widget.exercise,
                  'reps': reps,
                  'weight': weights,
                  'sets': sets,
                });
              } else {
                // Handle validation or show an error message
              }
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
