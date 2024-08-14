import 'package:flutter/material.dart';
import 'package:fusion_workouts/features/user_auth/presentation/models/food.dart';
import 'package:fusion_workouts/features/user_auth/presentation/widgets/edit_food_dialog.dart';

class MealSummaryWidget extends StatelessWidget {
  final List<Food> meals;
  final String mealName;
  final num totalCalories;
  final double proteinIntake;
  final double carbIntake;
  final double fatIntake;
  final VoidCallback onTap;
  final Function(List<Food>) onUpdate;
  final EdgeInsetsGeometry padding;

  const MealSummaryWidget({
    super.key,
    required this.meals,
    required this.mealName,
    required this.totalCalories,
    required this.proteinIntake,
    required this.carbIntake,
    required this.fatIntake,
    required this.onTap,
    required this.onUpdate,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mealName,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(237, 255, 134, 21),
                        ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: onTap,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => EditFoodDialog(
                              meals: meals,
                              onUpdate: onUpdate,
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8.0),
              _buildNutritionalInfo('Calories', '$totalCalories kcal'),
              _buildNutritionalInfo(
                  'Protein', '${proteinIntake.toStringAsFixed(2)}g'),
              _buildNutritionalInfo(
                  'Carbs', '${carbIntake.toStringAsFixed(2)}g'),
              _buildNutritionalInfo('Fats', '${fatIntake.toStringAsFixed(2)}g'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionalInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
