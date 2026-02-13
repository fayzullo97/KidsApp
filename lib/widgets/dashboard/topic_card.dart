import 'package:flutter/material.dart';
import 'package:kids_learning_app/models/dashboard/topic_stats.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TopicCard extends StatelessWidget {
  final TopicStats topic;
  final VoidCallback onTap;

  const TopicCard({super.key, required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color progressColor;
    if (topic.completionPercentage >= 80) {
      progressColor = Colors.green;
    } else if (topic.completionPercentage >= 40) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    topic.topicName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${topic.completionPercentage.toInt()}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearPercentIndicator(
                lineHeight: 8.0,
                percent: (topic.completionPercentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                progressColor: progressColor,
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
                animation: true,
                animationDuration: 1000,
              ),
              const SizedBox(height: 8),
              Text(
                '${topic.learnedUnits} / ${topic.totalUnits} Units Learned',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
