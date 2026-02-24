import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/persona_binding.dart';
import '../repositories/persona_repository.dart';

@injectable
class BindPersonaUseCase {
  final PersonaRepository _repository;

  BindPersonaUseCase(this._repository);

  Future<Either<Failure, PersonaBinding>> call(
    String personaId, {
    String? nickname,
  }) =>
      _repository.bindPersona(personaId, nickname: nickname);
}
