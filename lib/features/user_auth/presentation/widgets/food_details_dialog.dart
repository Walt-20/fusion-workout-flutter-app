import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';

class FoodDetailsDialog extends StatefulWidget {
  final Food food;

  const FoodDetailsDialog({Key? key, required this.food}) : super(key: key);

  @override
  _FoodDetailsDialogState createState() => _FoodDetailsDialogState();
}

class _FoodDetailsDialogState extends State<FoodDetailsDialog> {
  final TextEditingController _servingsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _servingsController.text = widget.food.servings.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Details for ${widget.food.foodName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _servingsController,
              decoration:
                  const InputDecoration(labelText: 'Number of Servings'),
              keyboardType: TextInputType.number,
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
            setState(() {
              // widget.food.servings = int.parse(_servingsController.text);
              // debugPrint("${widget.food.servings}");
              debugPrint("${widget.food.foodName}");
            });
            Navigator.of(context).pop(widget.food);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
