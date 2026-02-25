import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/learning_path.dart';
import '../../domain/entities/progress_report.dart';
import '../../domain/repositories/career_repository.dart';
import '../datasources/career_remote_data_source.dart';

@Injectable(as: CareerRepository)
class CareerRepositoryImpl implements CareerRepository {
  CareerRepositoryImpl(this._remote);
  final CareerRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Goal>>> getGoals({String? status}) async {
    try {
      final list = await _remote.getGoals(status: status);
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
  Future<Either<Failure, Goal>> createGoal({
    required String title,
    String? description,
    String? parentId,
    String? priority,
    String? deadline,
    double? estimatedHours,
  }) async {
    try {
      final goal = await _remote.createGoal(
        title: title,
        description: description,
        parentId: parentId,
        priority: priority,
        deadline: deadline,
        estimatedHours: estimatedHours,
      );
      return Right(goal);
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
  Future<Either<Failure, Goal>> updateGoal(
    String goalId, {
    double? progressPercent,
    String? status,
  }) async {
    try {
      final goal = await _remote.updateGoal(
        goalId,
        progressPercent: progressPercent,
        status: status,
      );
      return Right(goal);
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
  Future<Either<Failure, List<LearningPath>>> getLearningPaths() async {
    try {
      final list = await _remote.getLearningPaths();
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
  Future<Either<Failure, LearningPath>> generateLearningPath({
    required List<String> interests,
    required String goalDescription,
  }) async {
    try {
      final path = await _remote.generateLearningPath(
        interests: interests,
        goalDescription: goalDescription,
      );
      return Right(path);
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
  Future<Either<Failure, List<ProgressReport>>> getProgressReports() async {
    try {
      final list = await _remote.getProgressReports();
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
  Future<Either<Failure, ProgressReport>> generateProgressReport({
    required String periodStart,
    required String periodEnd,
  }) async {
    try {
      final report = await _remote.generateProgressReport(
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      return Right(report);
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
