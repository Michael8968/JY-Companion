import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/goal.dart';
import '../repositories/career_repository.dart';

@injectable
class GetGoalsUseCase {
  GetGoalsUseCase(this._repository);
  final CareerRepository _repository;

  Future<Either<Failure, List<Goal>>> call({String? status}) =>
      _repository.getGoals(status: status);
}
