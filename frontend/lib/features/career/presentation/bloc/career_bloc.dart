import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/create_goal_usecase.dart';
import '../../domain/usecases/generate_progress_report_usecase.dart';
import '../../domain/usecases/get_goals_usecase.dart';
import '../../domain/usecases/get_progress_reports_usecase.dart';
import '../../domain/usecases/update_goal_usecase.dart';
import 'career_event.dart';
import 'career_state.dart';

@injectable
class CareerBloc extends Bloc<CareerEvent, CareerState> {
  CareerBloc(
    this._getGoals,
    this._createGoal,
    this._updateGoal,
    this._getReports,
    this._generateReport,
  ) : super(const CareerState()) {
    on<CareerLoadEvent>(_onLoad);
    on<CareerCreateGoalEvent>(_onCreateGoal);
    on<CareerUpdateGoalEvent>(_onUpdateGoal);
    on<CareerLoadReportsEvent>(_onLoadReports);
    on<CareerGenerateReportEvent>(_onGenerateReport);
  }

  final GetGoalsUseCase _getGoals;
  final CreateGoalUseCase _createGoal;
  final UpdateGoalUseCase _updateGoal;
  final GetProgressReportsUseCase _getReports;
  final GenerateProgressReportUseCase _generateReport;

  Future<void> _onLoad(
    CareerLoadEvent event,
    Emitter<CareerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final goalsResult = await _getGoals();
    final reportsResult = await _getReports();
    goalsResult.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (goals) {
        reportsResult.fold(
          (failure) => emit(state.copyWith(
            isLoading: false,
            goals: goals,
            errorMessage: failure.message,
          )),
          (reports) => emit(state.copyWith(
            isLoading: false,
            goals: goals,
            reports: reports,
          )),
        );
      },
    );
  }

  Future<void> _onCreateGoal(
    CareerCreateGoalEvent event,
    Emitter<CareerState> emit,
  ) async {
    final result = await _createGoal(
      title: event.title,
      description: event.description,
      priority: event.priority,
      deadline: event.deadline,
      estimatedHours: event.estimatedHours,
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (goal) => emit(state.copyWith(
        goals: [goal, ...state.goals],
      )),
    );
  }

  Future<void> _onUpdateGoal(
    CareerUpdateGoalEvent event,
    Emitter<CareerState> emit,
  ) async {
    final result = await _updateGoal(
      event.goalId,
      progressPercent: event.progressPercent,
      status: event.status,
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (updated) => emit(state.copyWith(
        goals: state.goals
            .map((g) => g.id == updated.id ? updated : g)
            .toList(),
      )),
    );
  }

  Future<void> _onLoadReports(
    CareerLoadReportsEvent event,
    Emitter<CareerState> emit,
  ) async {
    final result = await _getReports();
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (reports) => emit(state.copyWith(reports: reports)),
    );
  }

  Future<void> _onGenerateReport(
    CareerGenerateReportEvent event,
    Emitter<CareerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _generateReport(
      periodStart: event.periodStart,
      periodEnd: event.periodEnd,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (report) => emit(state.copyWith(
        isLoading: false,
        reports: [report, ...state.reports],
      )),
    );
  }
}
