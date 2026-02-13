class UnitStats {
  final String unitId;
  final String unitName;
  final double masteryScore;
  final int correctCount;
  final int wrongCount;
  final String status; // 'Learned', 'In Progress', 'Not Started'

  UnitStats({
    required this.unitId,
    required this.unitName,
    required this.masteryScore,
    required this.correctCount,
    required this.wrongCount,
    required this.status,
  });

  factory UnitStats.fromJson(Map<String, dynamic> json) {
    return UnitStats(
      unitId: json['unit_id'] as String,
      unitName: json['unit_name'] as String,
      masteryScore: (json['mastery_score'] as num).toDouble(),
      correctCount: json['correct_count'] as int,
      wrongCount: json['wrong_count'] as int,
      status: json['status'] as String,
    );
  }
}
