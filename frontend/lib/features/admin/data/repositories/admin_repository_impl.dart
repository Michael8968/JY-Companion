import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/crisis_alert_summary.dart';
import '../../domain/entities/platform_stats.dart';
import '../../domain/entities/user_summary.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

@Injectable(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._remote);
  final AdminRemoteDataSource _remote;

  @override
  Future<Either<Failure, PlatformStats>> getStats() async {
    try {
      final stats = await _remote.getStats();
      return Right(stats);
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
  Future<Either<Failure, ({List<UserSummary> users, int total})>> getUsers({
    int page = 1,
    int size = 20,
    String? role,
  }) async {
    try {
      final result = await _remote.getUsers(page: page, size: size, role: role);
      return Right(result);
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
  Future<Either<Failure, void>> updateUserStatus(
    String userId,
    bool isActive,
  ) async {
    try {
      await _remote.updateUserStatus(userId, isActive);
      return const Right(null);
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
  Future<Either<Failure, ({List<CrisisAlertSummary> alerts, int total})>>
      getAlerts({
    int page = 1,
    int size = 20,
    String? status,
  }) async {
    try {
      final result =
          await _remote.getAlerts(page: page, size: size, status: status);
      return Right(result);
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
  Future<Either<Failure, void>> resolveAlert(String alertId,
      {String? notes}) async {
    try {
      await _remote.resolveAlert(alertId, notes: notes);
      return const Right(null);
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
