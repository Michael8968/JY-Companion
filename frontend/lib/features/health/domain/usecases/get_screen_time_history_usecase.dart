import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/screen_time_record.dart';
import '../repositories/health_repository.dart';

@injectable
class GetScreenTimeHistoryUseCase {
  GetScreenTimeHistoryUseCase(this._repository);
  final HealthRepository _repository;

  Future<Either<Failure, List<ScreenTimeRecord>>> call({int limit = 50}) =>
      _repository.getScreenTimeHistory(limit: limit);
}
