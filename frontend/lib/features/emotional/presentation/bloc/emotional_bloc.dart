import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/create_gratitude_entry_usecase.dart';
import '../../domain/usecases/get_emotion_history_usecase.dart';
import '../../domain/usecases/get_gratitude_entries_usecase.dart';
import 'emotional_event.dart';
import 'emotional_state.dart';

@injectable
class EmotionalBloc extends Bloc<EmotionalEvent, EmotionalState> {
  EmotionalBloc(
    this._getEmotionHistory,
    this._getGratitudeEntries,
    this._createGratitudeEntry,
  ) : super(const EmotionalState()) {
    on<EmotionalLoadEvent>(_onLoad);
    on<EmotionalCreateGratitudeEvent>(_onCreateGratitude);
  }

  final GetEmotionHistoryUseCase _getEmotionHistory;
  final GetGratitudeEntriesUseCase _getGratitudeEntries;
  final CreateGratitudeEntryUseCase _createGratitudeEntry;

  Future<void> _onLoad(
    EmotionalLoadEvent event,
    Emitter<EmotionalState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final emotionResult = await _getEmotionHistory(limit: 30);
    final gratitudeResult = await _getGratitudeEntries(limit: 20);
    emotionResult.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (emotions) {
        gratitudeResult.fold(
          (failure) => emit(state.copyWith(
            isLoading: false,
            emotions: emotions,
            errorMessage: failure.message,
          )),
          (entries) => emit(state.copyWith(
            isLoading: false,
            emotions: emotions,
            gratitudeEntries: entries,
          )),
        );
      },
    );
  }

  Future<void> _onCreateGratitude(
    EmotionalCreateGratitudeEvent event,
    Emitter<EmotionalState> emit,
  ) async {
    final result = await _createGratitudeEntry(event.content);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (entry) => emit(state.copyWith(
        gratitudeEntries: [entry, ...state.gratitudeEntries],
      )),
    );
  }
}
