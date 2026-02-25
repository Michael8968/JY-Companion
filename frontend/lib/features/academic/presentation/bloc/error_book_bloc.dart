import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/get_error_book_usecase.dart';
import '../../domain/usecases/review_error_usecase.dart';
import 'error_book_event.dart';
import 'error_book_state.dart';

@injectable
class ErrorBookBloc extends Bloc<ErrorBookEvent, ErrorBookState> {
  ErrorBookBloc(this._getErrorBook, this._reviewError)
      : super(const ErrorBookState()) {
    on<ErrorBookLoadEvent>(_onLoad);
    on<ErrorBookReviewEvent>(_onReview);
  }

  final GetErrorBookUseCase _getErrorBook;
  final ReviewErrorUseCase _reviewError;

  Future<void> _onLoad(
    ErrorBookLoadEvent event,
    Emitter<ErrorBookState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentSubject: event.subject,
    ));
    final result = await _getErrorBook(
      subject: event.subject,
      page: 1,
      size: 20,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
        errors: [],
      )),
      (data) => emit(state.copyWith(
        isLoading: false,
        errors: data.errors,
        total: data.total,
        page: data.page,
        size: data.size,
      )),
    );
  }

  Future<void> _onReview(
    ErrorBookReviewEvent event,
    Emitter<ErrorBookState> emit,
  ) async {
    emit(state.copyWith(isReviewing: true, errorMessage: null));
    final result = await _reviewError(event.errorId);
    result.fold(
      (failure) => emit(state.copyWith(
        isReviewing: false,
        errorMessage: failure.message,
      )),
      (updated) {
        final list = state.errors.map((e) {
          if (e.id == updated.id) return updated;
          return e;
        }).toList();
        emit(state.copyWith(errors: list, isReviewing: false));
      },
    );
  }
}
