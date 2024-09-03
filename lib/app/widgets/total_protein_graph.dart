import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProteinIntakeChart extends StatelessWidget {
  final num totalProtein;

  ProteinIntakeChart({required this.totalProtein});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final date =
                    DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text('${date.month}/${date.day}'),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, totalProtein.toDouble())
            ], // Only one data point for the day
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            belowBarData:
                BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}
