// import 'package:intl/intl.dart';

// class Food {
//   String foodId;
//   String foodName;
//   String foodType;
//   dynamic foodSubCategories;
//   String foodUrl;
//   dynamic servings;
//   String day;
//   Food({
//     required this.foodId,
//     required this.foodName,
//     required this.foodType,
//     required this.foodSubCategories,
//     required this.foodUrl,
//     required this.servings,
//     String? day,
//   }) : this.day = day ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

//   factory Food.fromJson(Map<String, dynamic> json) {
//     return Food(
//       foodId: json['food_id'],
//       foodName: json['food_name'],
//       foodType: json['food_type'],
//       foodSubCategories: json['food_sub_categoires'],
//       foodUrl: json['food_url'],
//       servings: json['servings'],
//     );
//   }

//   // Private method to extract numeric value from nutritional value string
//   double _extractNutrientValue(String valueString, String nutrientName) {
//     String nutrientValueString =
//         valueString.split(": ")[1].replaceAll(RegExp(r'[a-zA-Z]'), '');
//     return double.parse(nutrientValueString);
//   }

//   // Method to convert Food object to map
//   Map<String, dynamic> toJson() {
//     return {
//       'food_id': foodId,
//       'food_name': foodName,
//       'food_type': foodType,
//       'food_url': foodUrl,
//       'food_sub_categories': foodSubCategories,
//       'servings': servings,
//       'food_day': day,
//     };
//   }

//   // Method to create Food object from map
//   factory Food.fromMap(Map<String, dynamic> map) {
//     return Food(
//       foodId: map['food_id'],
//       foodName: map['food_name'],
//       foodType: map['food_type'],
//       foodSubCategories: map['food_sub_categories'],
//       foodUrl: map['food_url'],
//       servings: map['servings'],
//       day: map['food_day'],
//     );
//   }
// }

import 'dart:convert';

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
  final String serving_id;
  final String serving_description;
  final String calories;

  Serving({
    required this.serving_id,
    required this.serving_description,
    required this.calories,
  });

  factory Serving.fromJson(Map<String, dynamic> json) {
    return Serving(
      serving_id: json['serving_id'],
      serving_description: json['serving_description'],
      calories: json['calories'],
    );
  }
}
