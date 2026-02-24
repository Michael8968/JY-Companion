import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/persona.dart';
import '../../domain/entities/persona_binding.dart';
import '../../domain/repositories/persona_repository.dart';
import '../datasources/persona_remote_data_source.dart';

@Injectable(as: PersonaRepository)
class PersonaRepositoryImpl implements PersonaRepository {
  final PersonaRemoteDataSource _remoteDataSource;

  PersonaRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Persona>>> listPersonas() async {
    try {
      final models = await _remoteDataSource.listPersonas();
      return Right(models
          .map((m) => Persona(
                id: m.id,
                name: m.name,
                displayName: m.displayName,
                avatarUrl: m.avatarUrl,
                description: m.description,
                personalityTraits: m.personalityTraits,
                speakingStyle: m.speakingStyle,
                tone: m.tone,
                catchphrase: m.catchphrase,
                vocabularyLevel: m.vocabularyLevel,
                emojiUsage: m.emojiUsage,
                humorLevel: m.humorLevel,
                formality: m.formality,
                empathyLevel: m.empathyLevel,
                knowledgeDomains: m.knowledgeDomains,
                preferredAgentTypes: m.preferredAgentTypes,
                responseLength: m.responseLength,
                encouragementStyle: m.encouragementStyle,
                teachingApproach: m.teachingApproach,
                isPreset: m.isPreset,
                isActive: m.isActive,
                version: m.version,
                createdAt: m.createdAt,
              ))
          .toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonaBinding>> bindPersona(
    String personaId, {
    String? nickname,
  }) async {
    try {
      final model = await _remoteDataSource.bindPersona(
        personaId,
        nickname: nickname,
      );
      return Right(PersonaBinding(
        id: model.id,
        userId: model.userId,
        personaId: model.personaId,
        nickname: model.nickname,
        isActive: model.isActive,
        isDefault: model.isDefault,
        interactionCount: model.interactionCount,
        createdAt: model.createdAt,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PersonaBinding>>> listMyBindings() async {
    try {
      final models = await _remoteDataSource.listMyBindings();
      return Right(models
          .map((m) => PersonaBinding(
                id: m.id,
                userId: m.userId,
                personaId: m.personaId,
                nickname: m.nickname,
                isActive: m.isActive,
                isDefault: m.isDefault,
                interactionCount: m.interactionCount,
                createdAt: m.createdAt,
              ))
          .toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
