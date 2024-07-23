class Food {
  String foodId;
  String foodName;
  String foodDescription;
  String foodUrl;
  double calories;
  double fats;
  double carbs;
  double protein;
  int servings;

  Food({
    required this.foodId,
    required this.foodName,
    required this.foodDescription,
    required this.foodUrl,
    this.calories = 0.0,
    this.fats = 0.0,
    this.carbs = 0.0,
    this.protein = 0.0,
    this.servings = 1,
  });

  // Method to parse food_description and extract nutritional values
  void parseNutritionalValues() {
    // Extract nutritional values from food_description
    List<String> nutritionalValues = foodDescription.split(" | ");
    for (String value in nutritionalValues) {
      if (value.contains("Calories")) {
        calories = _extractNutrientValue(value, "Calories");
      } else if (value.contains("Fat")) {
        fats = _extractNutrientValue(value, "Fat");
      } else if (value.contains("Carbs")) {
        carbs = _extractNutrientValue(value, "Carbs");
      } else if (value.contains("Protein")) {
        protein = _extractNutrientValue(value, "Protein");
      }
    }
  }

  // Private method to extract numeric value from nutritional value string
  double _extractNutrientValue(String valueString, String nutrientName) {
    String nutrientValueString =
        valueString.split(": ")[1].replaceAll(RegExp(r'[a-zA-Z]'), '');
    return double.parse(nutrientValueString);
  }

  // Method to convert Food object to map
  Map<String, dynamic> toMap() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'food_description': foodDescription,
      'food_url': foodUrl,
      'calories': calories,
      'fat': fats,
      'carbs': carbs,
      'protein': protein,
      'servings': servings,
    };
  }

  // Method to create Food object from map
  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      foodId: map['food_id'],
      foodName: map['food_name'],
      foodDescription: map['food_description'],
      foodUrl: map['food_url'],
    );
  }

  @override
  String toString() {
    return '{food_id: $foodId, food_name: $foodName, food_description: $foodDescription, servings: $servings, food_url: $foodUrl}';
  }
}
