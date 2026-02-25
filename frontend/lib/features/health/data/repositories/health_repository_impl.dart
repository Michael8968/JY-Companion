import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exercise_plan.dart';
import '../../domain/entities/reminder_config.dart';
import '../../domain/entities/screen_time_record.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_data_source.dart';

@Injectable(as: HealthRepository)
class HealthRepositoryImpl implements HealthRepository {
  HealthRepositoryImpl(this._remote);
  final HealthRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ScreenTimeRecord>>> getScreenTimeHistory({
    int limit = 50,
  }) async {
    try {
      final list = await _remote.getScreenTimeHistory(limit: limit);
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
  Future<Either<Failure, ReminderConfig>> getReminderConfig() async {
    try {
      final config = await _remote.getReminderConfig();
      return Right(config);
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
  Future<Either<Failure, ReminderConfig>> updateReminderConfig(
    Map<String, dynamic> body,
  ) async {
    try {
      final config = await _remote.updateReminderConfig(body);
      return Right(config);
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
  Future<Either<Failure, ExercisePlan>> getExercisePlan({
    String planType = 'stretch',
  }) async {
    try {
      final plan = await _remote.getExercisePlan(planType: planType);
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

  @override
  Future<Either<Failure, ExercisePlan>> completeExercise(String planId) async {
    try {
      final plan = await _remote.completeExercise(planId);
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
