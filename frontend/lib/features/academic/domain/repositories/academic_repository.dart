import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/error_book_result.dart';
import '../entities/error_record.dart';
import '../entities/subject.dart';

abstract class AcademicRepository {
  Future<Either<Failure, ErrorBookResult>> getErrorBook({
    Subject? subject,
    int page,
    int size,
  });

  Future<Either<Failure, ErrorRecord>> reviewError(String errorId);
}
