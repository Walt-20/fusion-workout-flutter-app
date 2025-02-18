class Food {
  final String foodId;
  final String foodName;
  final String brandName;
  final List<Serving> servings;

  Food({
    required this.foodId,
    required this.foodName,
    required this.brandName,
    required this.servings,
  });

  // Factory method to create a FoodItem from JSON
  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      foodId: json['food_id'],
      foodName: json['food_name'],
      brandName: json['brand_name'] ?? '',
      servings: (json['servings']['serving'] as List)
          .map((s) => Serving.fromJson(s))
          .toList(),
    );
  }

  // Method to convert FoodItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
    };
  }
}

class Serving {
  final String servingId;
  final String servingDescription;
  final String calories;

  Serving({
    required this.servingId,
    required this.servingDescription,
    required this.calories,
  });

  factory Serving.fromJson(Map<String, dynamic> json) {
    return Serving(
      servingId: json['serving_id'],
      servingDescription: json['serving_description'],
      calories: json['calories'],
    );
  }
}
