import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/persona.dart';
import '../repositories/persona_repository.dart';

@injectable
class ListPersonasUseCase {
  final PersonaRepository _repository;

  ListPersonasUseCase(this._repository);

  Future<Either<Failure, List<Persona>>> call() => _repository.listPersonas();
}
