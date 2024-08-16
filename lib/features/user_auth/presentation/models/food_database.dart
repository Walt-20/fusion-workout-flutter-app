class FoodForDatabase {
  String foodId;
  String servingId;
  String numberOfServings;
  String totalCalories;
  String totalProtein;

  FoodForDatabase({
    required this.foodId,
    required this.servingId,
    required this.numberOfServings,
    required this.totalCalories,
    required this.totalProtein,
  });

  static FoodForDatabase fromMap(Map<String, dynamic> foodItem) {
    return FoodForDatabase(
      foodId: foodItem['foodId'],
      servingId: foodItem['servingId'],
      numberOfServings: foodItem['numberOfServings'],
      totalCalories: foodItem['totalCalories'],
      totalProtein: foodItem['totalProtein'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'servingId': servingId,
      'numberOfServings': numberOfServings,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
    };
  }
}
