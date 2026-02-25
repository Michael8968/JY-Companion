import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/error_book_result.dart';
import '../../domain/entities/error_record.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/academic_repository.dart';
import '../datasources/academic_remote_data_source.dart';

@Injectable(as: AcademicRepository)
class AcademicRepositoryImpl implements AcademicRepository {
  AcademicRepositoryImpl(this._remote);

  final AcademicRemoteDataSource _remote;

  @override
  Future<Either<Failure, ErrorBookResult>> getErrorBook({
    Subject? subject,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _remote.getErrorBook(
        subject: subject,
        page: page,
        size: size,
      );
      final result = ErrorBookResult(
        errors: response.errors,
        total: response.total,
        page: response.page,
        size: response.size,
      );
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
  Future<Either<Failure, ErrorRecord>> reviewError(String errorId) async {
    try {
      final record = await _remote.reviewError(errorId);
      return Right(record);
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
