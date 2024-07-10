import 'package:flutter/material.dart';

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({super.key});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final TextEditingController _eventNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create Workout"),
      content: TextField(
        controller: _eventNameController,
        decoration: InputDecoration(labelText: "Workout Name"),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
          final eventName = _eventNameController.text;
          if (eventName.isNotEmpty) {
            Navigator.of(context).pop(eventName);
          }
        },
          child: Text("Create"),
        ),
      ],
    );
  }
}