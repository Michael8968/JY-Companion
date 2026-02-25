import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/goal.dart';
import '../repositories/career_repository.dart';

@injectable
class UpdateGoalUseCase {
  UpdateGoalUseCase(this._repository);
  final CareerRepository _repository;

  Future<Either<Failure, Goal>> call(
    String goalId, {
    double? progressPercent,
    String? status,
  }) =>
      _repository.updateGoal(
        goalId,
        progressPercent: progressPercent,
        status: status,
      );
}
