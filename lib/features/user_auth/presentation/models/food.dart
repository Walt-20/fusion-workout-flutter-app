import 'package:intl/intl.dart';

class FoodSearchResponse {
  final FoodSearch foodsSearch;
  String day;

  FoodSearchResponse({
    required this.foodsSearch,
    String? day,
  }) : this.day = day ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

  factory FoodSearchResponse.fromJson(Map<String, dynamic> json) {
    return FoodSearchResponse(
      foodsSearch: FoodSearch.fromJson(json['foods_search']),
    );
  }
}

class FoodSearch {
  final String maxResults;
  final String totalResults;
  final String pageNumber;
  final FoodResults results;

  FoodSearch({
    required this.maxResults,
    required this.totalResults,
    required this.pageNumber,
    required this.results,
  });

  factory FoodSearch.fromJson(Map<String, dynamic> json) {
    return FoodSearch(
      maxResults: json['max_results'],
      totalResults: json['total_results'],
      pageNumber: json['page_number'],
      results: FoodResults.fromJson(json['results']),
    );
  }
}

class FoodResults {
  final List<FoodItem> food;

  FoodResults({required this.food});

  factory FoodResults.fromJson(Map<String, dynamic> json) {
    // Handle the case where 'food' is a single object instead of a list
    dynamic foodData = json['food'];
    if (foodData is List) {
      return FoodResults(
        food: foodData.map((item) => FoodItem.fromJson(item)).toList(),
      );
    } else {
      return FoodResults(
        food: [FoodItem.fromJson(foodData)],
      );
    }
  }
}

class FoodItem {
  final String foodId;
  final String foodName;
  final String brandName;
  final String foodType;
  final List<String> foodSubCategories;
  final String foodUrl;
  final FoodAttributes foodAttributes;
  final List<Serving> servings;

  FoodItem({
    required this.foodId,
    required this.foodName,
    required this.brandName,
    required this.foodType,
    required this.foodSubCategories,
    required this.foodUrl,
    required this.foodAttributes,
    required this.servings,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    var foodSubCategoriesData =
        json['food_sub_categories']['food_sub_category'];
    List<String> foodSubCategories = List<String>.from(foodSubCategoriesData);

    var servingsData = json['servings']['serving'];
    List<Serving> servings =
        servingsData.map((item) => Serving.fromJson(item)).toList();

    return FoodItem(
      foodId: json['food_id'],
      foodName: json['food_name'],
      brandName: json['brand_name'],
      foodType: json['food_type'],
      foodSubCategories: foodSubCategories,
      foodUrl: json['food_url'],
      foodAttributes: FoodAttributes.fromJson(json['food_attributes']),
      servings: servings,
    );
  }
}

class FoodAttributes {
  final List<Allergen> allergens;
  final List<Preference> preferences;

  FoodAttributes({required this.allergens, required this.preferences});

  factory FoodAttributes.fromJson(Map<String, dynamic> json) {
    var allergensData = json['allergens']['allergen'];
    List<Allergen> allergens =
        allergensData.map((item) => Allergen.fromJson(item)).toList();

    var preferencesData = json['preferences']['preference'];
    List<Preference> preferences =
        preferencesData.map((item) => Preference.fromJson(item)).toList();

    return FoodAttributes(
      allergens: allergens,
      preferences: preferences,
    );
  }
}

class Allergen {
  final String id;
  final String name;
  final String value;

  Allergen({required this.id, required this.name, required this.value});

  factory Allergen.fromJson(Map<String, dynamic> json) {
    return Allergen(
      id: json['id'],
      name: json['name'],
      value: json['value'],
    );
  }
}

class Preference {
  final String id;
  final String name;
  final String value;

  Preference({required this.id, required this.name, required this.value});

  factory Preference.fromJson(Map<String, dynamic> json) {
    return Preference(
      id: json['id'],
      name: json['name'],
      value: json['value'],
    );
  }
}

class Serving {
  final String servingId;
  final String servingDescription;
  final String servingUrl;
  final String metricServingAmount;
  final String metricServingUnit;
  final String numberOfUnits;
  final String measurementDescription;
  final String isDefault;
  final String calories;
  final String carbohydrate;
  final String protein;
  final String fat;
  final String saturatedFat;
  final String polyunsaturatedFat;
  final String monounsaturatedFat;
  final String transFat;
  final String cholesterol;
  final String sodium;
  final String potassium;
  final String fiber;
  final String sugar;
  final String addedSugars;
  final String vitaminD;
  final String vitaminA;
  final String vitaminC;
  final String calcium;
  final String iron;

  Serving({
    required this.servingId,
    required this.servingDescription,
    required this.servingUrl,
    required this.metricServingAmount,
    required this.metricServingUnit,
    required this.numberOfUnits,
    required this.measurementDescription,
    required this.isDefault,
    required this.calories,
    required this.carbohydrate,
    required this.protein,
    required this.fat,
    required this.saturatedFat,
    required this.polyunsaturatedFat,
    required this.monounsaturatedFat,
    required this.transFat,
    required this.cholesterol,
    required this.sodium,
    required this.potassium,
    required this.fiber,
    required this.sugar,
    required this.addedSugars,
    required this.vitaminD,
    required this.vitaminA,
    required this.vitaminC,
    required this.calcium,
    required this.iron,
  });

  factory Serving.fromJson(Map<String, dynamic> json) {
    return Serving(
      servingId: json['serving_id'],
      servingDescription: json['serving_description'],
      servingUrl: json['serving_url'],
      metricServingAmount: json['metric_serving_amount'],
      metricServingUnit: json['metric_serving_unit'],
      numberOfUnits: json['number_of_units'],
      measurementDescription: json['measurement_description'],
      isDefault: json['is_default'],
      calories: json['calories'],
      carbohydrate: json['carbohydrate'],
      protein: json['protein'],
      fat: json['fat'],
      saturatedFat: json['saturated_fat'],
      polyunsaturatedFat: json['polyunsaturated_fat'],
      monounsaturatedFat: json['monounsaturated_fat'],
      transFat: json['trans_fat'],
      cholesterol: json['cholesterol'],
      sodium: json['sodium'],
      potassium: json['potassium'],
      fiber: json['fiber'],
      sugar: json['sugar'],
      addedSugars: json['added_sugars'],
      vitaminD: json['vitamin_d'],
      vitaminA: json['vitamin_a'],
      vitaminC: json['vitamin_c'],
      calcium: json['calcium'],
      iron: json['iron'],
    );
  }
}
