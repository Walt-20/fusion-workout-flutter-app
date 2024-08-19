import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fusion_workouts/app/models/food.dart';
import 'package:http/http.dart' as http;

enum MealType { breakfast, lunch, dinner, snack }

typedef UpdateNutritionalValues = void Function(
  double totalCalories,
  double totalProtein,
  double totalCarbs,
  double totalFats,
  Food updatedFood,
  int servings,
);

class AddFoodDialog extends StatefulWidget {
  final MealType mealType;
  final UpdateNutritionalValues updateNutritionalValues;

  const AddFoodDialog({
    super.key,
    required this.mealType,
    required this.updateNutritionalValues,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddFoodDialogState createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  int _multiplier = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Food to ${widget.mealType.toString().split('.').last}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                key: const Key('searchController'),
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search for food',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _fetchSearchFood(_searchController.text);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            if (_searchResults.isEmpty)
              const Center(child: Text('No results found'))
            else
              Column(
                children: List.generate(_searchResults.length, (index) {
                  final food = _searchResults[index];
                  return ListTile(
                    title: Text(food['food_name']),
                    subtitle: Text(food['food_description'] ?? ''),
                    onTap: () {
                      _showAddToMealDialog(food);
                    },
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchSearchFood(String query) async {
    final url = Uri.parse('http://10.0.2.2:3000/search-food');

    try {
      final response =
          await http.get(Uri.parse('$url?searchExpression=$query'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final foods = List<Map<String, dynamic>>.from(jsonData);

        setState(() {
          _searchResults = foods;
        });
      } else {
        debugPrint("Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _showAddToMealDialog(dynamic food) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Food"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Servings", style: TextStyle(fontSize: 16)),
                        DropdownButton<int>(
                          key: const Key('DropdownMenu'),
                          value: _multiplier,
                          items: List.generate(10, (index) => index + 1)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() => _multiplier = newValue!);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  key: const Key('AddFoodButton'),
                  child: const Text('Add'),
                  onPressed: () {
                    // _addToMeal(food, _multiplier);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
