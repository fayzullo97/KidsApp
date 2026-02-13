class UserProgress {
  final String childId;
  final String unitId;
  double masteryScore; // 0.0 to 1.0

  UserProgress({
    required this.childId,
    required this.unitId,
    this.masteryScore = 0.0,
  });
}
