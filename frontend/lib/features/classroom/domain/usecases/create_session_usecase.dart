import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/classroom_session.dart';
import '../repositories/classroom_repository.dart';

@injectable
class CreateSessionUseCase {
  CreateSessionUseCase(this._repository);
  final ClassroomRepository _repository;

  Future<Either<Failure, ClassroomSession>> call({
    required String title,
    required String subject,
    String? audioUrl,
    int? durationSeconds,
  }) =>
      _repository.createSession(
        title: title,
        subject: subject,
        audioUrl: audioUrl,
        durationSeconds: durationSeconds,
      );
}
