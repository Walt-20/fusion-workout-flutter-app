import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';

class FoodDetailsDialog extends StatefulWidget {
  final Food food;
  final DateTime date;

  const FoodDetailsDialog({Key? key, required this.food, required this.date})
      : super(key: key);

  @override
  _FoodDetailsDialogState createState() => _FoodDetailsDialogState();
}

class _FoodDetailsDialogState extends State<FoodDetailsDialog> {
  final TextEditingController _servingsController = TextEditingController();
  String? _selectedServingId;
  String _numberOfServings = "1";
  String _totalCalories = "0";
  String _totalProtein = "0";
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();

    if (widget.food.servings.isNotEmpty) {
      _selectedServingId = widget.food.servings.first.serving_id;
      fetchServingIdNutritionalData(_selectedServingId!);
    }
  }

  Future<void> fetchServingIdNutritionalData(String servingId) async {
    var map = await _auth.fetchFoodItemByServingId(widget.date, servingId);

    if (map != null) {
      setState(() {
        _totalCalories = map['totalCalories'];
        _totalProtein = map['totalProtein'];
        _numberOfServings = map['numberOfServings'];
      });
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
                debugPrint('Serving ID: ${value.serving_id}');
                return DropdownMenuItem<String>(
                  value: value.serving_id,
                  child: Text(value.serving_description),
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
              decoration: InputDecoration(
                labelText: 'Number of Servings',
                hintText: 'Enter number of servings',
                suffixText: _numberOfServings,
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 8.0,
            ),
            Text("Total Calories: $_totalCalories"),
            SizedBox(
              height: 8.0,
            ),
            Text("Total Protein: $_totalProtein"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_selectedServingId != null) {
              final servings = _servingsController.text ?? "1";
              Navigator.of(context).pop({
                'food': widget.food,
                'servingId': _selectedServingId,
                'numberOfServings': servings,
              });
            }
          },
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _numberOfServings = _servingsController.text.isNotEmpty
                  ? _servingsController.text
                  : "1";

              int numServings = int.parse(_numberOfServings);
              String selectedServingId = _selectedServingId!;
              var serving = widget.food.servings.firstWhere(
                (serving) => serving.serving_id == selectedServingId,
                orElse: () => widget.food.servings.first,
              );
              int calories = int.parse(serving.calories);
              int totalCalories = numServings * calories;
              _totalCalories = totalCalories.toString();
              double protein = double.parse(serving.protein);
              double totalProtein = numServings * protein;
              _totalProtein = totalProtein.toStringAsFixed(2);
            });
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
