/// 学习路径
class LearningPath {
  const LearningPath({
    required this.id,
    required this.title,
    this.description,
    this.resources,
    required this.currentStage,
    required this.totalStages,
    this.interestTags,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final Map<String, dynamic>? resources;
  final int currentStage;
  final int totalStages;
  final Map<String, dynamic>? interestTags;
  final DateTime createdAt;

  double get progress =>
      totalStages > 0 ? currentStage / totalStages : 0.0;

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    return LearningPath(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      resources: json['resources'] as Map<String, dynamic>?,
      currentStage: json['current_stage'] as int? ?? 0,
      totalStages: json['total_stages'] as int? ?? 1,
      interestTags: json['interest_tags'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
