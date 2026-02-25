import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/crisis_alert_summary.dart';
import '../repositories/admin_repository.dart';

@injectable
class GetAlertsUseCase {
  GetAlertsUseCase(this._repository);
  final AdminRepository _repository;

  Future<Either<Failure, ({List<CrisisAlertSummary> alerts, int total})>> call({
    int page = 1,
    int size = 20,
    String? status,
  }) =>
      _repository.getAlerts(page: page, size: size, status: status);
}
