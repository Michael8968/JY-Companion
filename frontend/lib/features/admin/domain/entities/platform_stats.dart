/// 平台统计
class PlatformStats {
  const PlatformStats({
    required this.totalUsers,
    required this.activeUsersToday,
    required this.totalConversations,
    required this.totalMessages,
    required this.activeCrisisAlerts,
    this.avgResponseTimeMs,
  });

  final int totalUsers;
  final int activeUsersToday;
  final int totalConversations;
  final int totalMessages;
  final int activeCrisisAlerts;
  final double? avgResponseTimeMs;

  factory PlatformStats.fromJson(Map<String, dynamic> json) {
    return PlatformStats(
      totalUsers: json['total_users'] as int? ?? 0,
      activeUsersToday: json['active_users_today'] as int? ?? 0,
      totalConversations: json['total_conversations'] as int? ?? 0,
      totalMessages: json['total_messages'] as int? ?? 0,
      activeCrisisAlerts: json['active_crisis_alerts'] as int? ?? 0,
      avgResponseTimeMs: (json['avg_response_time_ms'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformStats &&
          runtimeType == other.runtimeType &&
          totalUsers == other.totalUsers &&
          activeUsersToday == other.activeUsersToday &&
          totalConversations == other.totalConversations &&
          totalMessages == other.totalMessages &&
          activeCrisisAlerts == other.activeCrisisAlerts &&
          avgResponseTimeMs == other.avgResponseTimeMs;

  @override
  int get hashCode => Object.hash(
        totalUsers,
        activeUsersToday,
        totalConversations,
        totalMessages,
        activeCrisisAlerts,
        avgResponseTimeMs,
      );
}
