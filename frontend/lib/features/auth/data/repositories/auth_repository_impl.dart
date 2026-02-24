import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/token_manager.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenManager _tokenManager;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenManager);

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final tokenModel = await _remoteDataSource.login(
        LoginRequestModel(username: username, password: password),
      );

      await _tokenManager.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );

      final userModel = await _remoteDataSource.getCurrentUser();
      await _tokenManager.saveCurrentUser(userModel.toJson());

      return Right(User(
        id: userModel.id,
        username: userModel.username,
        displayName: userModel.displayName,
        role: userModel.role,
        email: userModel.email,
        avatarUrl: userModel.avatarUrl,
        grade: userModel.grade,
        className: userModel.className,
        studentId: userModel.studentId,
        lastLoginAt: userModel.lastLoginAt,
        createdAt: userModel.createdAt,
      ));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String username,
    required String password,
    required String displayName,
    String role = 'student',
    String? email,
    String? phone,
    String? grade,
    String? className,
    String? studentId,
  }) async {
    try {
      final userModel = await _remoteDataSource.register(
        RegisterRequestModel(
          username: username,
          password: password,
          displayName: displayName,
          role: role,
          email: email,
          phone: phone,
          grade: grade,
          className: className,
          studentId: studentId,
        ),
      );

      return Right(User(
        id: userModel.id,
        username: userModel.username,
        displayName: userModel.displayName,
        role: userModel.role,
        email: userModel.email,
        avatarUrl: userModel.avatarUrl,
        grade: userModel.grade,
        className: userModel.className,
        studentId: userModel.studentId,
        lastLoginAt: userModel.lastLoginAt,
        createdAt: userModel.createdAt,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _tokenManager.clearTokens();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try cached user first
      final cached = _tokenManager.cachedUser;
      if (cached != null && _tokenManager.hasTokens) {
        try {
          final userModel = await _remoteDataSource.getCurrentUser();
          await _tokenManager.saveCurrentUser(userModel.toJson());
          return Right(User(
            id: userModel.id,
            username: userModel.username,
            displayName: userModel.displayName,
            role: userModel.role,
            email: userModel.email,
            avatarUrl: userModel.avatarUrl,
            grade: userModel.grade,
            className: userModel.className,
            studentId: userModel.studentId,
            lastLoginAt: userModel.lastLoginAt,
            createdAt: userModel.createdAt,
          ));
        } on NetworkException {
          // Fallback to cached user on network failure
          return Right(User(
            id: cached['id'] as String,
            username: cached['username'] as String,
            displayName: cached['display_name'] as String,
            role: cached['role'] as String,
            email: cached['email'] as String?,
            avatarUrl: cached['avatar_url'] as String?,
            grade: cached['grade'] as String?,
            className: cached['class_name'] as String?,
            studentId: cached['student_id'] as String?,
            createdAt: DateTime.parse(cached['created_at'] as String),
          ));
        }
      }

      if (!_tokenManager.hasTokens) {
        return const Left(UnauthorizedFailure());
      }

      final userModel = await _remoteDataSource.getCurrentUser();
      await _tokenManager.saveCurrentUser(userModel.toJson());

      return Right(User(
        id: userModel.id,
        username: userModel.username,
        displayName: userModel.displayName,
        role: userModel.role,
        email: userModel.email,
        avatarUrl: userModel.avatarUrl,
        grade: userModel.grade,
        className: userModel.className,
        studentId: userModel.studentId,
        lastLoginAt: userModel.lastLoginAt,
        createdAt: userModel.createdAt,
      ));
    } on UnauthorizedException {
      await _tokenManager.clearTokens();
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
