import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';

class EditFoodDialog extends StatefulWidget {
  final List<Food> meals;
  final Function(List<Food>) onUpdate;

  const EditFoodDialog({
    super.key,
    required this.meals,
    required this.onUpdate,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditFoodDialogState createState() => _EditFoodDialogState();
}

class _EditFoodDialogState extends State<EditFoodDialog> {
  void _deleteMeal(Food meal) {
    setState(() {
      widget.meals.remove(meal);
    });
    widget.onUpdate(widget.meals);
  }

  void _editMeal(BuildContext context, Food meal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${meal.foodName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text('Current servings: ${meal.servings}'),
              const SizedBox(height: 12),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'New servings',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {},
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                widget.onUpdate(widget.meals);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Foods'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final meal in widget.meals)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(meal.foodName),
                  trailing: IconButton(
                    onPressed: () {
                      _deleteMeal(meal);
                    },
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                  ),
                  onTap: () {
                    _editMeal(context, meal);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
