import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/evaluate_result.dart';
import '../repositories/creative_repository.dart';

@injectable
class EvaluateWorkUseCase {
  EvaluateWorkUseCase(this._repository);
  final CreativeRepository _repository;

  Future<Either<Failure, EvaluateResult>> call({
    required String text,
    String? genre,
  }) =>
      _repository.evaluate(text: text, genre: genre);
}
