import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/exercise_plan.dart';
import '../entities/reminder_config.dart';
import '../entities/screen_time_record.dart';

abstract class HealthRepository {
  Future<Either<Failure, List<ScreenTimeRecord>>> getScreenTimeHistory({
    int limit,
  });

  Future<Either<Failure, ReminderConfig>> getReminderConfig();

  Future<Either<Failure, ReminderConfig>> updateReminderConfig(
    Map<String, dynamic> body,
  );

  Future<Either<Failure, ExercisePlan>> getExercisePlan({
    String planType,
  });

  Future<Either<Failure, ExercisePlan>> completeExercise(String planId);
}
