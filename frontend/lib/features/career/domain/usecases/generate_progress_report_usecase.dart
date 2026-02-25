import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/progress_report.dart';
import '../repositories/career_repository.dart';

@injectable
class GenerateProgressReportUseCase {
  GenerateProgressReportUseCase(this._repository);
  final CareerRepository _repository;

  Future<Either<Failure, ProgressReport>> call({
    required String periodStart,
    required String periodEnd,
  }) =>
      _repository.generateProgressReport(
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
}
