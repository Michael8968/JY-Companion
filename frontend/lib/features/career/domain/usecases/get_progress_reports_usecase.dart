import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/progress_report.dart';
import '../repositories/career_repository.dart';

@injectable
class GetProgressReportsUseCase {
  GetProgressReportsUseCase(this._repository);
  final CareerRepository _repository;

  Future<Either<Failure, List<ProgressReport>>> call() =>
      _repository.getProgressReports();
}
