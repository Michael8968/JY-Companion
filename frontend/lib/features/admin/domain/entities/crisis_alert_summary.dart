/// 危机预警摘要
class CrisisAlertSummary {
  const CrisisAlertSummary({
    required this.id,
    required this.userId,
    required this.alertLevel,
    required this.status,
    required this.triggerType,
    required this.triggerContent,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String alertLevel;
  final String status;
  final String triggerType;
  final String triggerContent;
  final DateTime createdAt;

  String get alertLevelDisplay {
    switch (alertLevel) {
      case 'critical':
        return '严重';
      case 'high':
        return '高';
      case 'medium':
        return '中';
      case 'low':
        return '低';
      default:
        return alertLevel;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'active':
        return '待处理';
      case 'acknowledged':
        return '已确认';
      case 'resolved':
        return '已解决';
      default:
        return status;
    }
  }

  factory CrisisAlertSummary.fromJson(Map<String, dynamic> json) {
    return CrisisAlertSummary(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      alertLevel: json['alert_level'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'active',
      triggerType: json['trigger_type'] as String? ?? '',
      triggerContent: json['trigger_content'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrisisAlertSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          alertLevel == other.alertLevel &&
          status == other.status &&
          triggerType == other.triggerType &&
          triggerContent == other.triggerContent &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        alertLevel,
        status,
        triggerType,
        triggerContent,
        createdAt,
      );
}
