import 'package:flutter/material.dart';
import 'package:kids_learning_app/models/dashboard/topic_stats.dart';
import 'package:kids_learning_app/widgets/dashboard/unit_list_tile.dart';
import 'package:kids_learning_app/widgets/dashboard/progress_chart.dart';

class TopicDetailScreen extends StatelessWidget {
  final TopicStats topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(topic.topicName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${topic.completionPercentage.toInt()}% Completed',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: topic.completionPercentage >= 80 ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${topic.learnedUnits} of ${topic.totalUnits} units mastered'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Performance Analytics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ProgressChartWidget(units: topic.units),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Knowledge Units',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...topic.units.map((unit) => UnitListTile(unit: unit)),
        ],
      ),
    );
  }
}
