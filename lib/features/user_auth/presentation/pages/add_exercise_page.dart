import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:intl/intl.dart'; // Ensure you have this for date formatting

class AddExercisePage extends StatefulWidget {
  final String? exerciseMuscle;
  final String? exerciseName;
  final DateTime selectedDate;

  const AddExercisePage({
    super.key,
    this.exerciseMuscle,
    this.exerciseName,
    required this.selectedDate,
  });

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  FirebaseAuthService _auth = FirebaseAuthService();
  late TextEditingController _repsController;
  late TextEditingController _setsController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController();
    _setsController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _repsController.dispose();
    _setsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    // Validate inputs
    if (_repsController.text.isEmpty ||
        _setsController.text.isEmpty ||
        _weightController.text.isEmpty) {
      // Show error message
      return;
    }

    // Create exercise map
    Map<String, dynamic> exercise = {
      'name': widget.exerciseName,
      'muscle': widget.exerciseMuscle,
      'reps': int.parse(_repsController.text),
      'sets': int.parse(_setsController.text),
      'weight': double.parse(_weightController.text),
    };

    // Add exercise to Firestore
    await _auth.addExerciseToFirestore(widget.selectedDate, [exercise]);

    // Close the dialog
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Exercise'),
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
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addExercise,
          child: const Text('Add Exercise'),
        ),
      ],
    );
  }
}
