import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/persona.dart';
import '../entities/persona_binding.dart';

abstract class PersonaRepository {
  Future<Either<Failure, List<Persona>>> listPersonas();
  Future<Either<Failure, PersonaBinding>> bindPersona(
    String personaId, {
    String? nickname,
  });
  Future<Either<Failure, List<PersonaBinding>>> listMyBindings();
}
