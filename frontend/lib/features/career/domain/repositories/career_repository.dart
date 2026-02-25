import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/goal.dart';
import '../entities/learning_path.dart';
import '../entities/progress_report.dart';

abstract class CareerRepository {
  Future<Either<Failure, List<Goal>>> getGoals({String? status});

  Future<Either<Failure, Goal>> createGoal({
    required String title,
    String? description,
    String? parentId,
    String? priority,
    String? deadline,
    double? estimatedHours,
  });

  Future<Either<Failure, Goal>> updateGoal(
    String goalId, {
    double? progressPercent,
    String? status,
  });

  Future<Either<Failure, List<LearningPath>>> getLearningPaths();

  Future<Either<Failure, LearningPath>> generateLearningPath({
    required List<String> interests,
    required String goalDescription,
  });

  Future<Either<Failure, List<ProgressReport>>> getProgressReports();

  Future<Either<Failure, ProgressReport>> generateProgressReport({
    required String periodStart,
    required String periodEnd,
  });
}
