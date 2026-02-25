import '../../domain/entities/crisis_alert_summary.dart';
import '../../domain/entities/platform_stats.dart';
import '../../domain/entities/user_summary.dart';

class AdminState {
  const AdminState({
    this.stats,
    this.users = const [],
    this.usersTotal = 0,
    this.alerts = const [],
    this.alertsTotal = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  final PlatformStats? stats;
  final List<UserSummary> users;
  final int usersTotal;
  final List<CrisisAlertSummary> alerts;
  final int alertsTotal;
  final bool isLoading;
  final String? errorMessage;

  AdminState copyWith({
    PlatformStats? stats,
    List<UserSummary>? users,
    int? usersTotal,
    List<CrisisAlertSummary>? alerts,
    int? alertsTotal,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      users: users ?? this.users,
      usersTotal: usersTotal ?? this.usersTotal,
      alerts: alerts ?? this.alerts,
      alertsTotal: alertsTotal ?? this.alertsTotal,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminState &&
          runtimeType == other.runtimeType &&
          stats == other.stats &&
          _listEquals(users, other.users) &&
          usersTotal == other.usersTotal &&
          _listEquals(alerts, other.alerts) &&
          alertsTotal == other.alertsTotal &&
          isLoading == other.isLoading &&
          errorMessage == other.errorMessage;

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        stats,
        Object.hashAll(users),
        usersTotal,
        Object.hashAll(alerts),
        alertsTotal,
        isLoading,
        errorMessage,
      );
}
