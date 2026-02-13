import 'package:flutter/material.dart';
import 'package:kids_learning_app/models/dashboard/unit_stats.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class UnitListTile extends StatelessWidget {
  final UnitStats unit;

  const UnitListTile({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (unit.status == 'Learned') {
      statusColor = Colors.green;
    } else if (unit.status == 'In Progress') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  unit.unitName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    unit.status,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearPercentIndicator(
              lineHeight: 6.0,
              percent: unit.masteryScore.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              progressColor: statusColor,
              barRadius: const Radius.circular(3),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Text(
              'Correct: ${unit.correctCount} | Wrong: ${unit.wrongCount}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
