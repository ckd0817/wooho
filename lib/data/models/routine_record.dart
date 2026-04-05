/// 舞段训练记录数据模型
class RoutineRecord {
  final int? id;
  final String routineId;
  final String feedback;
  final int reviewedAt;
  final int previousMastery;
  final int newMastery;

  RoutineRecord({
    this.id,
    required this.routineId,
    required this.feedback,
    required this.reviewedAt,
    required this.previousMastery,
    required this.newMastery,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'routine_id': routineId,
        'feedback': feedback,
        'reviewed_at': reviewedAt,
        'previous_mastery': previousMastery,
        'new_mastery': newMastery,
      };

  factory RoutineRecord.fromJson(Map<String, dynamic> json) => RoutineRecord(
        id: json['id'] as int?,
        routineId: json['routine_id'] as String,
        feedback: json['feedback'] as String,
        reviewedAt: json['reviewed_at'] as int,
        previousMastery: json['previous_mastery'] as int,
        newMastery: json['new_mastery'] as int,
      );
}
