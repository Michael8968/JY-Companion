/// 个性化学案
class StudyPlan {
  const StudyPlan({
    required this.id,
    required this.planType,
    this.content,
    this.reviewPoints,
    this.exercises,
    this.extensions,
    required this.createdAt,
  });

  final String id;
  final String planType;
  final String? content;
  final Map<String, dynamic>? reviewPoints;
  final Map<String, dynamic>? exercises;
  final Map<String, dynamic>? extensions;
  final DateTime createdAt;

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      id: json['id'] as String,
      planType: json['plan_type'] as String? ?? 'basic',
      content: json['content'] as String?,
      reviewPoints: json['review_points'] as Map<String, dynamic>?,
      exercises: json['exercises'] as Map<String, dynamic>?,
      extensions: json['extensions'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
