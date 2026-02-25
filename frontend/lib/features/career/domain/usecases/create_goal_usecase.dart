import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/goal.dart';
import '../repositories/career_repository.dart';

@injectable
class CreateGoalUseCase {
  CreateGoalUseCase(this._repository);
  final CareerRepository _repository;

  Future<Either<Failure, Goal>> call({
    required String title,
    String? description,
    String? parentId,
    String? priority,
    String? deadline,
    double? estimatedHours,
  }) =>
      _repository.createGoal(
        title: title,
        description: description,
        parentId: parentId,
        priority: priority,
        deadline: deadline,
        estimatedHours: estimatedHours,
      );
}
