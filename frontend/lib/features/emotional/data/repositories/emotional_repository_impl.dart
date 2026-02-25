import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/emotion_record.dart';
import '../../domain/entities/gratitude_entry.dart';
import '../../domain/repositories/emotional_repository.dart';
import '../datasources/emotional_remote_data_source.dart';

@Injectable(as: EmotionalRepository)
class EmotionalRepositoryImpl implements EmotionalRepository {
  EmotionalRepositoryImpl(this._remote);
  final EmotionalRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<EmotionRecord>>> getEmotionHistory({
    int limit = 20,
  }) async {
    try {
      final list = await _remote.getEmotionHistory(limit: limit);
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
  Future<Either<Failure, List<GratitudeEntry>>> getGratitudeEntries({
    int limit = 20,
  }) async {
    try {
      final list = await _remote.getGratitudeEntries(limit: limit);
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
  Future<Either<Failure, GratitudeEntry>> createGratitudeEntry(
    String content,
  ) async {
    try {
      final entry = await _remote.createGratitudeEntry(content);
      return Right(entry);
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
