class FoodForDatabase {
  String foodId;
  String servingId;
  String numberOfServings;

  FoodForDatabase({
    required this.foodId,
    required this.servingId,
    required this.numberOfServings,
  });

  static FoodForDatabase fromMap(Map<String, dynamic> foodItem) {
    return FoodForDatabase(
      foodId: foodItem['foodId'],
      servingId: foodItem['servingId'],
      numberOfServings: foodItem['numberOfServings'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'servingId': servingId,
      'numberOfServings': numberOfServings,
    };
  }
}
