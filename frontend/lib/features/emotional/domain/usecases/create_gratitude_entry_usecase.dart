import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/gratitude_entry.dart';
import '../repositories/emotional_repository.dart';

@injectable
class CreateGratitudeEntryUseCase {
  CreateGratitudeEntryUseCase(this._repository);
  final EmotionalRepository _repository;

  Future<Either<Failure, GratitudeEntry>> call(String content) =>
      _repository.createGratitudeEntry(content);
}
