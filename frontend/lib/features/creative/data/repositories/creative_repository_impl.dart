import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/evaluate_result.dart';
import '../../domain/entities/generate_result.dart';
import '../../domain/repositories/creative_repository.dart';
import '../datasources/creative_remote_data_source.dart';

@Injectable(as: CreativeRepository)
class CreativeRepositoryImpl implements CreativeRepository {
  CreativeRepositoryImpl(this._remote);
  final CreativeRemoteDataSource _remote;

  @override
  Future<Either<Failure, GenerateResult>> generate({
    required String topic,
    String? style,
  }) async {
    try {
      final data = await _remote.generate(topic: topic, style: style);
      return Right(GenerateResult.fromJson(data));
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
  Future<Either<Failure, EvaluateResult>> evaluate({
    required String text,
    String? genre,
  }) async {
    try {
      final data = await _remote.evaluate(text: text, genre: genre);
      return Right(EvaluateResult.fromJson(data));
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
  Future<Either<Failure, String>> brainstorm({
    required String context,
    String? stuckPoint,
  }) async {
    try {
      final data = await _remote.brainstorm(
        context: context,
        stuckPoint: stuckPoint,
      );
      final inspiration = data['inspiration'] as String? ?? '';
      return Right(inspiration);
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
  Future<Either<Failure, Map<String, dynamic>>> optimize({
    required String text,
  }) async {
    try {
      final data = await _remote.optimize(text: text);
      return Right(data);
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
