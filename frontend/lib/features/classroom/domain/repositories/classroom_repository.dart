import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/classroom_doubt.dart';
import '../entities/classroom_session.dart';
import '../entities/study_plan.dart';

abstract class ClassroomRepository {
  Future<Either<Failure, ClassroomSession>> createSession({
    required String title,
    required String subject,
    String? audioUrl,
    int? durationSeconds,
  });

  Future<Either<Failure, ClassroomSession>> transcribeSession(String sessionId);

  Future<Either<Failure, ClassroomSession>> getSession(String sessionId);

  Future<Either<Failure, List<ClassroomDoubt>>> getSessionDoubts(String sessionId);

  Future<Either<Failure, StudyPlan>> generateStudyPlan(String sessionId);
}
