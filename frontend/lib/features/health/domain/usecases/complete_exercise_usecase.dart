import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/exercise_plan.dart';
import '../repositories/health_repository.dart';

@injectable
class CompleteExerciseUseCase {
  CompleteExerciseUseCase(this._repository);
  final HealthRepository _repository;

  Future<Either<Failure, ExercisePlan>> call(String planId) =>
      _repository.completeExercise(planId);
}
