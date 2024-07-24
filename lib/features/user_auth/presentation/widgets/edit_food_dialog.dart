import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';

class EditFoodDialog extends StatefulWidget {
  final List<Food> meals;
  final Function(List<Food>) onUpdate;

  const EditFoodDialog({
    Key? key,
    required this.meals,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditFoodDialogState createState() => _EditFoodDialogState();
}

class _EditFoodDialogState extends State<EditFoodDialog> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  void _deleteMeal(Food meal) {
    setState(() {
      widget.meals.remove(meal);
    });
    widget.onUpdate(widget.meals);
  }

  void _editMeal(BuildContext context, Food meal) {
    int servings = meal.servings;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${meal.foodName}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current servings: ${meal.servings}'),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'New servings'),
                  onChanged: (value) {
                    servings = int.tryParse(value) ?? meal.servings;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Update'),
              onPressed: () {
                setState(() {
                  meal.servings = servings;
                });

                widget.onUpdate(widget.meals);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
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
      title: Text('Edit Foods'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final meal in widget.meals)
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(meal.foodName),
                      subtitle: Text(
                          'Description: ${meal.foodDescription}\nServings: ${meal.servings}'),
                      onTap: () {
                        _editMeal(context, meal);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: () {
                        _deleteMeal(meal);
                        _auth.removeMealFromFirestore(
                            meal, meal.day.toString());
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
