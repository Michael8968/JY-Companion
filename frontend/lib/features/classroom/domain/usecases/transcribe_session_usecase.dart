import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/classroom_session.dart';
import '../repositories/classroom_repository.dart';

@injectable
class TranscribeSessionUseCase {
  TranscribeSessionUseCase(this._repository);
  final ClassroomRepository _repository;

  Future<Either<Failure, ClassroomSession>> call(String sessionId) =>
      _repository.transcribeSession(sessionId);
}
