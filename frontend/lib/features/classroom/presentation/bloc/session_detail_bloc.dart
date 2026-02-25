import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/generate_study_plan_usecase.dart';
import '../../domain/usecases/get_session_doubts_usecase.dart';
import '../../domain/usecases/get_session_usecase.dart';
import 'session_detail_event.dart';
import 'session_detail_state.dart';

@injectable
class SessionDetailBloc extends Bloc<SessionDetailEvent, SessionDetailState> {
  SessionDetailBloc(
    this._getSession,
    this._getSessionDoubts,
    this._generateStudyPlan,
  ) : super(const SessionDetailState()) {
    on<SessionDetailLoadEvent>(_onLoad);
    on<SessionDetailGenerateStudyPlanEvent>(_onGenerateStudyPlan);
  }

  final GetSessionUseCase _getSession;
  final GetSessionDoubtsUseCase _getSessionDoubts;
  final GenerateStudyPlanUseCase _generateStudyPlan;

  Future<void> _onLoad(
    SessionDetailLoadEvent event,
    Emitter<SessionDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _getSession(event.sessionId);
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (session) async {
        emit(state.copyWith(
          isLoading: false,
          session: session,
        ));
        await _loadDoubts(event.sessionId, emit);
      },
    );
  }

  Future<void> _loadDoubts(
    String sessionId,
    Emitter<SessionDetailState> emit,
  ) async {
    emit(state.copyWith(isLoadingDoubts: true));
    final result = await _getSessionDoubts(sessionId);
    result.fold(
      (failure) => emit(state.copyWith(isLoadingDoubts: false)),
      (list) => emit(state.copyWith(
        doubts: list,
        isLoadingDoubts: false,
      )),
    );
  }

  Future<void> _onGenerateStudyPlan(
    SessionDetailGenerateStudyPlanEvent event,
    Emitter<SessionDetailState> emit,
  ) async {
    emit(state.copyWith(isLoadingStudyPlan: true, errorMessage: null));
    final result = await _generateStudyPlan(event.sessionId);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingStudyPlan: false,
        errorMessage: failure.message,
      )),
      (plan) => emit(state.copyWith(
        studyPlan: plan,
        isLoadingStudyPlan: false,
      )),
    );
  }
}
