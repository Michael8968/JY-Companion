import '../../domain/entities/emotion_record.dart';
import '../../domain/entities/gratitude_entry.dart';

class EmotionalState {
  const EmotionalState({
    this.emotions = const [],
    this.gratitudeEntries = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<EmotionRecord> emotions;
  final List<GratitudeEntry> gratitudeEntries;
  final bool isLoading;
  final String? errorMessage;

  EmotionalState copyWith({
    List<EmotionRecord>? emotions,
    List<GratitudeEntry>? gratitudeEntries,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EmotionalState(
      emotions: emotions ?? this.emotions,
      gratitudeEntries: gratitudeEntries ?? this.gratitudeEntries,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
