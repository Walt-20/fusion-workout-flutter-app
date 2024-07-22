import 'package:flutter/material.dart';

class MealSummaryWidget extends StatelessWidget {
  final String mealName;
  final num totalCalories;
  final double proteinIntake;
  final double carbIntake;

  const MealSummaryWidget({
    Key? key,
    required this.mealName,
    required this.totalCalories,
    required this.proteinIntake,
    required this.carbIntake,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mealName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.0),
          Text('Calories: $totalCalories'),
          Text('Protein: ${proteinIntake.toStringAsFixed(2)}g'),
          Text('Carbs: ${carbIntake.toStringAsFixed(2)}g'),
        ],
      ),
    );
  }
}
