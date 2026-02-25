import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/gratitude_entry.dart';
import '../repositories/emotional_repository.dart';

@injectable
class GetGratitudeEntriesUseCase {
  GetGratitudeEntriesUseCase(this._repository);
  final EmotionalRepository _repository;

  Future<Either<Failure, List<GratitudeEntry>>> call({int limit = 20}) =>
      _repository.getGratitudeEntries(limit: limit);
}
