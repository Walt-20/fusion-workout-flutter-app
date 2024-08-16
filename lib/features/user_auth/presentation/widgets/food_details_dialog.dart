import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';

class FoodDetailsDialog extends StatefulWidget {
  final Food food;

  const FoodDetailsDialog({super.key, required this.food});

  @override
  // ignore: library_private_types_in_public_api
  _FoodDetailsDialogState createState() => _FoodDetailsDialogState();
}

class _FoodDetailsDialogState extends State<FoodDetailsDialog> {
  final TextEditingController _servingsController = TextEditingController();
  String? _selectedServingId;

  @override
  void initState() {
    super.initState();
    if (widget.food.servings.isNotEmpty) {
      _selectedServingId = widget.food.servings.first.servingId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Details for ${widget.food.foodName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              items: widget.food.servings
                  .map<DropdownMenuItem<String>>((Serving value) {
                debugPrint('Serving ID: ${value.servingId}');
                return DropdownMenuItem<String>(
                  value: value.servingId,
                  child: Text(value.servingDescription),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedServingId = newValue;
                });
              },
              value: _selectedServingId,
              hint: const Text('Select a serving'),
            ),
            TextField(
              controller: _servingsController,
              decoration:
                  const InputDecoration(labelText: 'Number of Servings'),
              keyboardType: TextInputType.text,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedServingId != null) {
              final servings = _servingsController.text;
              Navigator.of(context).pop({
                'food': widget.food,
                'servingId': _selectedServingId,
                'numberOfServings': servings,
              });
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
