import 'package:kids_learning_app/models/dashboard/unit_stats.dart';

class TopicStats {
  final String topicId;
  final String topicName;
  final int totalUnits;
  final int learnedUnits;
  final double completionPercentage;
  final List<UnitStats> units;

  TopicStats({
    required this.topicId,
    required this.topicName,
    required this.totalUnits,
    required this.learnedUnits,
    required this.completionPercentage,
    required this.units,
  });

  factory TopicStats.fromJson(Map<String, dynamic> json) {
    var rawUnits = json['units'] as List<dynamic>? ?? [];
    List<UnitStats> parsedUnits = rawUnits
        .map((u) => UnitStats.fromJson(u as Map<String, dynamic>))
        .toList();

    return TopicStats(
      topicId: json['topic_id'] as String,
      topicName: json['topic_name'] as String,
      totalUnits: json['total_units'] as int,
      learnedUnits: json['learned_units'] as int,
      completionPercentage: (json['topic_completion_pct'] as num).toDouble(),
      units: parsedUnits,
    );
  }
}
