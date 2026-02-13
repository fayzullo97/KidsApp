import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kids_learning_app/models/dashboard/unit_stats.dart';

class ProgressChartWidget extends StatelessWidget {
  final List<UnitStats> units;

  const ProgressChartWidget({super.key, required this.units});

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.0,
          barTouchData: BarTouchData(
            enabled: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < units.length) {
                    final name = units[index].unitName;
                    // Show first 3 chars or acronym if long
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        name.length > 4 ? name.substring(0, 3) : name,
                        style: const TextStyle(color: Colors.black, fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: units.asMap().entries.map((entry) {
            final index = entry.key;
            final unit = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: unit.masteryScore.clamp(0.0, 1.0),
                  color: unit.masteryScore >= 0.8 ? Colors.green : Colors.orange,
                  width: 12,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
