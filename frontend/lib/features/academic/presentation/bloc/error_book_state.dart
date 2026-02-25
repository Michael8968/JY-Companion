import '../../domain/entities/error_record.dart';
import '../../domain/entities/subject.dart';

class ErrorBookState {
  const ErrorBookState({
    this.errors = const [],
    this.total = 0,
    this.page = 1,
    this.size = 20,
    this.currentSubject,
    this.isLoading = false,
    this.errorMessage,
    this.isReviewing = false,
  });

  final List<ErrorRecord> errors;
  final int total;
  final int page;
  final int size;
  final Subject? currentSubject;
  final bool isLoading;
  final String? errorMessage;
  final bool isReviewing;

  ErrorBookState copyWith({
    List<ErrorRecord>? errors,
    int? total,
    int? page,
    int? size,
    Subject? currentSubject,
    bool? isLoading,
    String? errorMessage,
    bool? isReviewing,
  }) {
    return ErrorBookState(
      errors: errors ?? this.errors,
      total: total ?? this.total,
      page: page ?? this.page,
      size: size ?? this.size,
      currentSubject: currentSubject ?? this.currentSubject,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isReviewing: isReviewing ?? this.isReviewing,
    );
  }
}
