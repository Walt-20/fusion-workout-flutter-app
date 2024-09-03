import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fusion_workouts/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:fusion_workouts/app/models/food.dart';
import 'package:fusion_workouts/app/models/food_database.dart';
import 'package:fusion_workouts/app/widgets/floating_message.dart';
import 'package:fusion_workouts/app/widgets/food_details_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SearchFoodPage extends StatefulWidget {
  final VoidCallback onFoodAdded;
  final DateTime selectedDate;
  const SearchFoodPage({
    super.key,
    required this.selectedDate,
    required this.onFoodAdded,
  });

  @override
  State<SearchFoodPage> createState() => _SearchFoodPageState();
}

Future<List<Food>> fetchSuggestions(String query, int pageNumber) async {
  final url = Uri.parse(
      'http://proxy-backend-api-fusion-env.eba-semam5sh.us-east-2.elasticbeanstalk.com/search-food-3');

  try {
    final response = await http.get(
      Uri.parse('$url?searchExpression=$query&page_name=$pageNumber'),
    );

    if (response.statusCode == 200) {
      return parsedFoodItem(response.body);
    } else {
      debugPrint("what");
      throw Exception('Failed to load foods');
    }
  } catch (e) {
    throw Exception('OAuth Token has expired. Signout and log back in. ');
  }
}

List<Food> parsedFoodItem(String responseBody) {
  final parsed = jsonDecode(responseBody);

  var foodList = parsed['foods_search']['results']['food'] as List;

  return foodList.map<Food>((json) => Food.fromJson(json)).toList();
}

class _SearchFoodPageState extends State<SearchFoodPage> {
  final int _pageNumber = 0;
  int _selectedMealIndex = 0;
  final List<String> _mealOptions = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
  String _selectedMeal = 'Breakfast';
  Map<String, List<Food>> _selectedFoodsByMeal = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snacks': [],
  };
  // ignore: prefer_final_fields
  Map<String, List<FoodForDatabase>> _selectedFoodForDatabase = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snacks': [],
  };
  final FirebaseAuthService _auth = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    debugPrint("search food page is initialized");
    _fetchFoodFromDatabase();
  }

  Future<void> _addFoodMapToDatabase() async {
    debugPrint("adding food to database");
    await _auth.addFoodToDatabase(
        _selectedFoodForDatabase, widget.selectedDate);

    widget.onFoodAdded();
  }

  Future<void> _removeFoodFromDatabase(mealType, foodId, date) async {
    await _auth.removeFoodFromDatabase(mealType, foodId, date);
  }

  Future<void> _fetchFoodFromDatabase() async {
    debugPrint("fetch food from database within search food page");
    _selectedFoodsByMeal =
        await _auth.fetchFoodFromFirestore(widget.selectedDate);

    setState(() {});
  }

  List<double> _calculateNutritionalData(
      Food food, String servingId, String numberOfServings) {
    var calories = 0.0;
    var protein = 0.0;
    var parsedNumberOfServings = double.parse(numberOfServings);
    for (var serving in food.servings) {
      if (servingId == serving.servingId) {
        var parsedCalories = double.parse(serving.calories);
        var parsedProtein = double.parse(serving.protein);
        calories = parsedCalories * parsedNumberOfServings;
        protein = parsedProtein * parsedNumberOfServings;
      }
    }
    return [calories, protein];
  }

  void _updateSelectedFood(
      Food food, String servingId, String numberOfServings) {
    _selectedFoodForDatabase[_selectedMeal]!.add(FoodForDatabase(
      foodId: food.foodId,
      servingId: servingId,
      numberOfServings: numberOfServings,
    ));

    widget.onFoodAdded();
  }

  void _addOrRemoveSelectedFood(
      Food food, String servingId, String numberOfServings, bool isAdding) {
    setState(() {
      if (isAdding) {
        _selectedFoodsByMeal[_selectedMeal]!.add(food);
        _selectedFoodForDatabase[_selectedMeal]!.add(FoodForDatabase(
          foodId: food.foodId,
          servingId: servingId,
          numberOfServings: numberOfServings,
        ));
        debugPrint(
            "what is _selectedFoodForDatabase now? ${_selectedFoodForDatabase['numberOfServings']}");
      } else {
        _selectedFoodsByMeal[_selectedMeal]!.remove(food);
        _selectedFoodForDatabase[_selectedMeal]!.removeWhere(
          (item) => item.foodId == food.foodId,
        );
        _removeFoodFromDatabase(_selectedMeal, food.foodId, DateTime.now());
      }
    });

    widget.onFoodAdded();
  }

  void _showFloatingMessage(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => FloatingMessage(
        foodCount: _selectedFoodsByMeal[_selectedMeal]!.length,
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the overlay entry after a short duration
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(237, 255, 134, 21),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                launchUrl(
                  Uri.parse('https://www.fatsecret.com'),
                );
              },
              child: SvgPicture.network(
                'https://platform.fatsecret.com/api/static/images/powered_by_fatsecret.svg',
                height: 25,
                width: 25,
              ),
            ),
          ),
          IconButton(
            key: const Key('logoutButton'),
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(context),
          ),
        ],
      ),
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
              color: const Color.fromARGB(237, 255, 134, 21),
              selectedColor: Colors.white,
              fillColor: const Color.fromARGB(255, 255, 134, 21),
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
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.65,
                child: ListView.builder(
                  itemCount: _selectedFoodsByMeal[_selectedMeal]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final foodList = _selectedFoodsByMeal[_selectedMeal] ?? [];
                    return ListTile(
                      title: Text(foodList[index].foodName),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final result =
                                    await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return FoodDetailsDialog(
                                      food: foodList[index],
                                      date: widget.selectedDate,
                                    );
                                  },
                                );
                                if (result != null) {
                                  final food = result['food'] as Food;
                                  final servingId =
                                      result['servingId'] as String;
                                  debugPrint(
                                      "what is the servingId? $servingId");
                                  final numberOfServings =
                                      result['numberOfServings'] as String;
                                  _updateSelectedFood(
                                      food, servingId, numberOfServings);
                                  _addFoodMapToDatabase();
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _addOrRemoveSelectedFood(
                                      _selectedFoodsByMeal[_selectedMeal]![
                                          index],
                                      _selectedFoodsByMeal[_selectedMeal]![
                                              index]
                                          .servings
                                          .first
                                          .servingId,
                                      "1",
                                      false);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
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
                String searchQuery = controller.text;
                var searchFuture = fetchSuggestions(searchQuery, _pageNumber);

                return [
                  FutureBuilder<List<Food>>(
                    future: searchFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator(
                          color: Color.fromARGB(237, 255, 134, 21),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No results found');
                      } else {
                        final list = snapshot.data!;

                        return Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: list.length,
                              itemBuilder: (BuildContext context, int index) {
                                final food = list[index];
                                final brandName = food.brandName.isNotEmpty
                                    ? "  (${food.brandName})"
                                    : "";
                                bool isChecked = false;
                                return StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return ListTile(
                                      leading: Checkbox(
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isChecked = value!;

                                            if (isChecked) {
                                              _addOrRemoveSelectedFood(
                                                  food,
                                                  food.servings.first.servingId,
                                                  "1",
                                                  true);
                                              _addFoodMapToDatabase();
                                            } else {
                                              _addOrRemoveSelectedFood(
                                                  food,
                                                  food.servings.first.servingId,
                                                  "1",
                                                  false);
                                            }
                                            _showFloatingMessage(context);
                                          });
                                        },
                                        activeColor: const Color.fromARGB(
                                            237, 255, 134, 21),
                                      ),
                                      title: Text(food.foodName + brandName),
                                      subtitle: Text(
                                        "${food.servings[0].servingDescription} - Calories: ${food.servings[0].calories}kcal",
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
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
