import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/crisis_alert_summary.dart';
import '../entities/platform_stats.dart';
import '../entities/user_summary.dart';

abstract class AdminRepository {
  Future<Either<Failure, PlatformStats>> getStats();

  Future<Either<Failure, ({List<UserSummary> users, int total})>> getUsers({
    int page,
    int size,
    String? role,
  });

  Future<Either<Failure, void>> updateUserStatus(String userId, bool isActive);

  Future<Either<Failure, ({List<CrisisAlertSummary> alerts, int total})>>
      getAlerts({
    int page,
    int size,
    String? status,
  });

  Future<Either<Failure, void>> resolveAlert(String alertId, {String? notes});
}
