import 'package:flutter/material.dart';

class AddEventDialog extends StatefulWidget {
  final String? exerciseMuscle;

  const AddEventDialog({
    super.key,
    this.exerciseMuscle,
  });

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  late TextEditingController _eventNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(text: widget.exerciseMuscle);
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Workout"),
      content: TextField(
        controller: _eventNameController,
        decoration: const InputDecoration(labelText: "Workout Name"),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final eventName = _eventNameController.text;
            if (eventName.isNotEmpty) {
              Navigator.of(context).pop(eventName);
            }
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
