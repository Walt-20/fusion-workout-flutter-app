class FoodForDatabase {
  String foodId;
  String servingId;
  String numberOfServings;

  FoodForDatabase({
    required this.foodId,
    required this.servingId,
    required this.numberOfServings,
  });

  FoodForDatabase getFoodItemDetails(foodItem) {
    return FoodForDatabase(
      foodId: foodId,
      servingId: servingId,
      numberOfServings: numberOfServings,
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
