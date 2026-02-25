import 'package:injectable/injectable.dart';

import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/emotion_record.dart';
import '../repositories/emotional_repository.dart';

@injectable
class GetEmotionHistoryUseCase {
  GetEmotionHistoryUseCase(this._repository);
  final EmotionalRepository _repository;

  Future<Either<Failure, List<EmotionRecord>>> call({int limit = 20}) =>
      _repository.getEmotionHistory(limit: limit);
}
