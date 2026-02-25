import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/classroom_doubt.dart';
import '../repositories/classroom_repository.dart';

@injectable
class GetSessionDoubtsUseCase {
  GetSessionDoubtsUseCase(this._repository);
  final ClassroomRepository _repository;

  Future<Either<Failure, List<ClassroomDoubt>>> call(String sessionId) =>
      _repository.getSessionDoubts(sessionId);
}
