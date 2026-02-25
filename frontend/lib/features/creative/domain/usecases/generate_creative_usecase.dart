import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/generate_result.dart';
import '../repositories/creative_repository.dart';

@injectable
class GenerateCreativeUseCase {
  GenerateCreativeUseCase(this._repository);
  final CreativeRepository _repository;

  Future<Either<Failure, GenerateResult>> call({
    required String topic,
    String? style,
  }) =>
      _repository.generate(topic: topic, style: style);
}
