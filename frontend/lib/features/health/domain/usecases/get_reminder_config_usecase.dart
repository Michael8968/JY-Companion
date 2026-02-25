import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/reminder_config.dart';
import '../repositories/health_repository.dart';

@injectable
class GetReminderConfigUseCase {
  GetReminderConfigUseCase(this._repository);
  final HealthRepository _repository;

  Future<Either<Failure, ReminderConfig>> call() =>
      _repository.getReminderConfig();
}
