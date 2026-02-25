import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/error_record.dart';
import '../repositories/academic_repository.dart';

@injectable
class ReviewErrorUseCase {
  ReviewErrorUseCase(this._repository);
  final AcademicRepository _repository;

  Future<Either<Failure, ErrorRecord>> call(String errorId) =>
      _repository.reviewError(errorId);
}
