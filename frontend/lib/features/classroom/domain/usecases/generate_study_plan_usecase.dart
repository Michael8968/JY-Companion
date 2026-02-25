import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/study_plan.dart';
import '../repositories/classroom_repository.dart';

@injectable
class GenerateStudyPlanUseCase {
  GenerateStudyPlanUseCase(this._repository);
  final ClassroomRepository _repository;

  Future<Either<Failure, StudyPlan>> call(String sessionId) =>
      _repository.generateStudyPlan(sessionId);
}
