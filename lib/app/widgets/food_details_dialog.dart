import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/app/models/food.dart';

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
      title: Text(
        'Enter Details for ${widget.food.foodName}',
        style: TextStyle(color: Colors.black),
      ),
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
              hint: const Text(
                'Select a serving',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            TextField(
              controller: _servingsController,
              decoration: InputDecoration(
                labelText: 'Number of Servings',
                labelStyle: TextStyle(
                  color: Color.fromARGB(237, 255, 134, 21),
                ),
                hintText: 'Enter number of servings',
                hintStyle: TextStyle(
                  color: Colors.black,
                ),
                suffixText: _numberOfServings,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(237, 255, 134, 21),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(237, 255, 134, 21),
                  ),
                ),
              ),
              keyboardType: TextInputType.text,
              onChanged: (value) {
                setState(() {
                  _numberOfServings = _servingsController.text.isNotEmpty
                      ? _servingsController.text
                      : "1";

                  int numServings;
                  try {
                    numServings = int.parse(_numberOfServings);
                  } catch (e) {
                    numServings = 1;
                  }

                  if (_selectedServingId != null) {
                    String selectedServingId = _selectedServingId!;
                    var serving = widget.food.servings.firstWhere(
                      (serving) => serving.serving_id == selectedServingId,
                      orElse: () => widget.food.servings.first,
                    );
                    int calories;
                    try {
                      calories = int.parse(serving.calories);
                    } catch (e) {
                      calories = 0;
                    }
                    int totalCalories = numServings * calories;
                    _totalCalories = totalCalories.toString();

                    double protein;
                    try {
                      protein = double.parse(serving.protein);
                    } catch (e) {
                      protein = 0.0;
                    }
                    double totalProtein = numServings * protein;
                    _totalProtein = totalProtein.toStringAsFixed(2);
                  }
                });
              },
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
          child: const Text(
            'Close',
            style: TextStyle(
              color: Color.fromARGB(237, 255, 134, 21),
            ),
          ),
        ),
        ElevatedButton(
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
          child: const Text(
            'Update',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(237, 255, 134, 21),
          ),
        ),
      ],
    );
  }
}
