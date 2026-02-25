/// 屏幕使用记录
class ScreenTimeRecord {
  const ScreenTimeRecord({
    required this.id,
    required this.durationSeconds,
    this.postureScore,
    this.faceDistanceCm,
    required this.continuousMinutes,
    required this.createdAt,
  });

  final String id;
  final int durationSeconds;
  final double? postureScore;
  final double? faceDistanceCm;
  final int continuousMinutes;
  final DateTime createdAt;

  int get durationMinutes => durationSeconds ~/ 60;

  factory ScreenTimeRecord.fromJson(Map<String, dynamic> json) {
    return ScreenTimeRecord(
      id: json['id'] as String,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      postureScore: (json['posture_score'] as num?)?.toDouble(),
      faceDistanceCm: (json['face_distance_cm'] as num?)?.toDouble(),
      continuousMinutes: json['continuous_minutes'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
