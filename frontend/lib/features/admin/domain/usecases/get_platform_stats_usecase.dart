import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/platform_stats.dart';
import '../repositories/admin_repository.dart';

@injectable
class GetPlatformStatsUseCase {
  GetPlatformStatsUseCase(this._repository);
  final AdminRepository _repository;

  Future<Either<Failure, PlatformStats>> call() => _repository.getStats();
}
