import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/evaluate_work_usecase.dart';
import '../../domain/usecases/generate_creative_usecase.dart';
import 'creative_event.dart';
import 'creative_state.dart';

@injectable
class CreativeBloc extends Bloc<CreativeEvent, CreativeState> {
  CreativeBloc(this._generate, this._evaluate) : super(const CreativeState()) {
    on<CreativeGenerateEvent>(_onGenerate);
    on<CreativeEvaluateEvent>(_onEvaluate);
    on<CreativeAddToLibraryEvent>(_onAddToLibrary);
  }

  final GenerateCreativeUseCase _generate;
  final EvaluateWorkUseCase _evaluate;

  Future<void> _onGenerate(
    CreativeGenerateEvent event,
    Emitter<CreativeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _generate(topic: event.topic, style: event.style);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        isLoading: false,
        generateResult: data,
        libraryItems: [
          CreativeWorkItem(
            topic: data.topic,
            content: data.content,
            createdAt: DateTime.now(),
          ),
          ...state.libraryItems,
        ].take(20).toList(),
      )),
    );
  }

  Future<void> _onEvaluate(
    CreativeEvaluateEvent event,
    Emitter<CreativeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _evaluate(text: event.text, genre: event.genre);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        isLoading: false,
        evaluateResult: data,
      )),
    );
  }

  void _onAddToLibrary(
    CreativeAddToLibraryEvent event,
    Emitter<CreativeState> emit,
  ) {
    final items = [
      CreativeWorkItem(
        topic: event.topic,
        content: event.content,
        createdAt: DateTime.now(),
      ),
      ...state.libraryItems,
    ].take(20).toList();
    emit(state.copyWith(libraryItems: items));
  }
}
