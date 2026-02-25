/// 目标实体（SMART 目标）
class Goal {
  const Goal({
    required this.id,
    this.parentId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.progressPercent,
    this.estimatedHours,
    this.deadline,
    this.smartCriteria,
    this.subTasks,
    required this.level,
    required this.createdAt,
  });

  final String id;
  final String? parentId;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final double progressPercent;
  final double? estimatedHours;
  final String? deadline;
  final Map<String, dynamic>? smartCriteria;
  final Map<String, dynamic>? subTasks;
  final int level;
  final DateTime createdAt;

  String get statusDisplay {
    switch (status) {
      case 'active':
        return '进行中';
      case 'completed':
        return '已完成';
      case 'paused':
        return '已暂停';
      case 'abandoned':
        return '已放弃';
      default:
        return status;
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case 'high':
        return '高';
      case 'medium':
        return '中';
      case 'low':
        return '低';
      default:
        return priority;
    }
  }

  DateTime? get deadlineDate {
    if (deadline == null || deadline!.isEmpty) return null;
    return DateTime.tryParse(deadline!);
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      parentId: json['parent_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      priority: json['priority'] as String? ?? 'medium',
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0,
      estimatedHours: (json['estimated_hours'] as num?)?.toDouble(),
      deadline: json['deadline'] as String?,
      smartCriteria: json['smart_criteria'] as Map<String, dynamic>?,
      subTasks: json['sub_tasks'] as Map<String, dynamic>?,
      level: json['level'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
