import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../entities/emotion_record.dart';
import '../entities/gratitude_entry.dart';

abstract class EmotionalRepository {
  Future<Either<Failure, List<EmotionRecord>>> getEmotionHistory({
    int limit,
  });

  Future<Either<Failure, List<GratitudeEntry>>> getGratitudeEntries({
    int limit,
  });

  Future<Either<Failure, GratitudeEntry>> createGratitudeEntry(String content);
}
