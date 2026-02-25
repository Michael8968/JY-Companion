import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/classroom_doubt.dart';
import '../../domain/entities/classroom_session.dart';
import '../../domain/entities/study_plan.dart';
import '../../domain/repositories/classroom_repository.dart';
import '../datasources/classroom_remote_data_source.dart';

@Injectable(as: ClassroomRepository)
class ClassroomRepositoryImpl implements ClassroomRepository {
  ClassroomRepositoryImpl(this._remote);
  final ClassroomRemoteDataSource _remote;

  @override
  Future<Either<Failure, ClassroomSession>> createSession({
    required String title,
    required String subject,
    String? audioUrl,
    int? durationSeconds,
  }) async {
    try {
      final session = await _remote.createSession(
        title: title,
        subject: subject,
        audioUrl: audioUrl,
        durationSeconds: durationSeconds,
      );
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClassroomSession>> transcribeSession(
    String sessionId,
  ) async {
    try {
      final session = await _remote.transcribeSession(sessionId);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClassroomSession>> getSession(String sessionId) async {
    try {
      final session = await _remote.getSession(sessionId);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClassroomDoubt>>> getSessionDoubts(
    String sessionId,
  ) async {
    try {
      final list = await _remote.getSessionDoubts(sessionId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudyPlan>> generateStudyPlan(String sessionId) async {
    try {
      final plan = await _remote.generateStudyPlan(sessionId);
      return Right(plan);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
