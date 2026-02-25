import '../../domain/entities/evaluate_result.dart';
import '../../domain/entities/generate_result.dart';


class CreativeWorkItem {
  const CreativeWorkItem({
    required this.topic,
    required this.content,
    required this.createdAt,
  });
  final String topic;
  final String content;
  final DateTime createdAt;
}

class CreativeState {
  const CreativeState({
    this.generateResult,
    this.evaluateResult,
    this.libraryItems = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final GenerateResult? generateResult;
  final EvaluateResult? evaluateResult;
  final List<CreativeWorkItem> libraryItems;
  final bool isLoading;
  final String? errorMessage;

  CreativeState copyWith({
    GenerateResult? generateResult,
    EvaluateResult? evaluateResult,
    List<CreativeWorkItem>? libraryItems,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CreativeState(
      generateResult: generateResult ?? this.generateResult,
      evaluateResult: evaluateResult ?? this.evaluateResult,
      libraryItems: libraryItems ?? this.libraryItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
