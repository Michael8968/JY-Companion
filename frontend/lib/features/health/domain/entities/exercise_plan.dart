/// 运动计划
class ExercisePlan {
  const ExercisePlan({
    required this.id,
    required this.planType,
    this.exercises,
    required this.durationMinutes,
    required this.completed,
    required this.createdAt,
  });

  final String id;
  final String planType;
  final Map<String, dynamic>? exercises;
  final int durationMinutes;
  final bool completed;
  final DateTime createdAt;

  String get planTypeDisplay {
    switch (planType) {
      case 'stretch':
        return '拉伸';
      case 'strength':
        return '力量';
      case 'coordination':
        return '协调';
      default:
        return planType;
    }
  }

  factory ExercisePlan.fromJson(Map<String, dynamic> json) {
    return ExercisePlan(
      id: json['id'] as String,
      planType: json['plan_type'] as String? ?? 'stretch',
      exercises: json['exercises'] as Map<String, dynamic>?,
      durationMinutes: json['duration_minutes'] as int? ?? 5,
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
