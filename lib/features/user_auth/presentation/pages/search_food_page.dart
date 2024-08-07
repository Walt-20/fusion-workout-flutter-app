import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';
import 'package:http/http.dart' as http;

class SearchFoodPage extends StatefulWidget {
  final DateTime selectedDate;
  const SearchFoodPage({
    super.key,
    required this.selectedDate,
  });

  @override
  State<SearchFoodPage> createState() => _SearchFoodPageState();
}

Future<List<Food>> fetchSuggestions(String query) async {
  debugPrint("What is the query? $query");
  final url = Uri.parse('http://10.0.2.2:3000/search-food');

  try {
    final request = await http.get(
      Uri.parse('$url?searchExpression=$query'),
    );

    debugPrint("what is the status code? ${request.statusCode}");

    if (request.statusCode == 200) {
      debugPrint("is the status code correct? ");
      debugPrint("RAW JSON Response: ${request.body}");

      List<dynamic> jsonData = json.decode(request.body);
      debugPrint("Parsed JSON data: $jsonData");

      final foodList = jsonData.map((json) => Food.fromJson(json)).toList();
      debugPrint("The food at position 0 is ${foodList[0].foodName}");
      return foodList;
    } else {
      debugPrint("what");
      throw Exception('Failed to load foods');
    }
  } catch (e) {
    throw Exception('OAuth Token has expired. Signout and log back in. ');
  }
}

class _SearchFoodPageState extends State<SearchFoodPage> {
  int _selectedMealIndex = 0;
  final List<String> _mealOptions = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
  String _selectedMeal = 'Breakfast';
  Map<String, List<Food>> _selectedFoodsByMeal = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snacks': [],
  };
  final TextEditingController _searchController = TextEditingController();
  FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    // TODO: implement initState
    debugPrint("search food page is initialized");
    // _fetchFoodFromDatabase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addFoodMapToDatabase(Map<String, List<Food>> food) async {
    await _auth.addFoodToDatabase(food, widget.selectedDate);
  }

  Future<void> _fetchFoodFromDatabase() async {
    debugPrint("fetch food from database within search food page");
    _selectedFoodsByMeal =
        await _auth.fetchFoodIdFromFirestore(widget.selectedDate);

    _selectedFoodsByMeal = {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Foods')),
      body: Column(
        children: [
          // Meal toggle buttons at the top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: List.generate(
                _mealOptions.length,
                (index) => index == _selectedMealIndex,
              ),
              onPressed: (index) {
                setState(() {
                  _selectedMealIndex = index;
                  _selectedMeal = _mealOptions[index];
                });
              },
              children: _mealOptions
                  .map((meal) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(meal),
                      ))
                  .toList(),
            ),
          ),
          // Expanded to push the search bar to the bottom
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.65,
                child: ListView.builder(
                  itemCount: _selectedFoodsByMeal[_selectedMeal]!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          _selectedFoodsByMeal[_selectedMeal]![index].foodName),
                      subtitle: Text(_selectedFoodsByMeal[_selectedMeal]![index]
                          .foodDescription),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchAnchor.bar(
              suggestionsBuilder: (context, controller) {
                final searchFuture = fetchSuggestions(controller.text);
                return [
                  FutureBuilder<List<Food>>(
                    future: searchFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No results found');
                      } else {
                        final list = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(list[index].foodName),
                              subtitle: Text(list[index].foodDescription),
                              onTap: () {
                                setState(() {
                                  _selectedFoodsByMeal[_selectedMeal]!
                                      .add(list[index]);
                                });
                                _addFoodMapToDatabase(_selectedFoodsByMeal);
                                // Hide keyboard and close the search bar
                                FocusScope.of(context).unfocus();
                                _searchController.clear(); // Clear search field
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }
}
