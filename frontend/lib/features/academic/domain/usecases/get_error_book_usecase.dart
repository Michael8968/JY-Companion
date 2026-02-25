import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/error_book_result.dart';
import '../entities/subject.dart';
import '../repositories/academic_repository.dart';

@injectable
class GetErrorBookUseCase {
  GetErrorBookUseCase(this._repository);
  final AcademicRepository _repository;

  Future<Either<Failure, ErrorBookResult>> call({
    Subject? subject,
    int page = 1,
    int size = 20,
  }) =>
      _repository.getErrorBook(subject: subject, page: page, size: size);
}
