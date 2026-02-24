import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/persona_binding.dart';
import '../repositories/persona_repository.dart';

@injectable
class ListBindingsUseCase {
  final PersonaRepository _repository;

  ListBindingsUseCase(this._repository);

  Future<Either<Failure, List<PersonaBinding>>> call() =>
      _repository.listMyBindings();
}
