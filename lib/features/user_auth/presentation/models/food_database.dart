class FoodForDatabase {
  String foodId;
  String servingId;

  FoodForDatabase({
    required this.foodId,
    required this.servingId,
  });

  FoodForDatabase getFoodItemDetails(foodItem) {
    return FoodForDatabase(
      foodId: foodId,
      servingId: servingId,
    );
  }
}
