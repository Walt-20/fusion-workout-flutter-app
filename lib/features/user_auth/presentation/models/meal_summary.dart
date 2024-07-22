import 'package:flutter/material.dart';

class MealSummaryWidget extends StatelessWidget {
  final String mealName;
  final num totalCalories;
  final double proteinIntake;
  final double carbIntake;
  final double fatIntake;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  const MealSummaryWidget({
    Key? key,
    required this.mealName,
    required this.totalCalories,
    required this.proteinIntake,
    required this.carbIntake,
    required this.fatIntake,
    required this.onTap,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

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
              Text(
                mealName,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(237, 255, 134, 21),
                    ),
              ),
              SizedBox(height: 8.0),
              _buildNutritionalInfo('Calories', '${totalCalories} kcal'),
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
          style: TextStyle(
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
