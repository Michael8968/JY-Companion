import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/complete_exercise_usecase.dart';
import '../../domain/usecases/get_exercise_plan_usecase.dart';
import '../../domain/usecases/get_reminder_config_usecase.dart';
import '../../domain/usecases/get_screen_time_history_usecase.dart';
import '../../domain/usecases/update_reminder_config_usecase.dart';
import 'health_event.dart';
import 'health_state.dart';

@injectable
class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc(
    this._getScreenTimeHistory,
    this._getReminderConfig,
    this._updateReminderConfig,
    this._getExercisePlan,
    this._completeExercise,
  ) : super(const HealthState()) {
    on<HealthLoadEvent>(_onLoad);
    on<HealthUpdateReminderEvent>(_onUpdateReminder);
    on<HealthLoadExercisePlanEvent>(_onLoadExercisePlan);
    on<HealthCompleteExerciseEvent>(_onCompleteExercise);
  }

  final GetScreenTimeHistoryUseCase _getScreenTimeHistory;
  final GetReminderConfigUseCase _getReminderConfig;
  final UpdateReminderConfigUseCase _updateReminderConfig;
  final GetExercisePlanUseCase _getExercisePlan;
  final CompleteExerciseUseCase _completeExercise;

  Future<void> _onLoad(
    HealthLoadEvent event,
    Emitter<HealthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final screenResult = await _getScreenTimeHistory(limit: 50);
    final reminderResult = await _getReminderConfig();
    await screenResult.fold(
      (failure) async {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
      (list) async {
        reminderResult.fold(
          (failure) => emit(state.copyWith(
            isLoading: false,
            screenTimeHistory: list,
            errorMessage: failure.message,
          )),
          (config) => emit(state.copyWith(
            isLoading: false,
            screenTimeHistory: list,
            reminderConfig: config,
          )),
        );
      },
    );
  }

  Future<void> _onUpdateReminder(
    HealthUpdateReminderEvent event,
    Emitter<HealthState> emit,
  ) async {
    final result = await _updateReminderConfig(event.config);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (config) => emit(state.copyWith(reminderConfig: config)),
    );
  }

  Future<void> _onLoadExercisePlan(
    HealthLoadExercisePlanEvent event,
    Emitter<HealthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _getExercisePlan(planType: event.planType);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      )),
      (plan) => emit(state.copyWith(
        isLoading: false,
        exercisePlan: plan,
      )),
    );
  }

  Future<void> _onCompleteExercise(
    HealthCompleteExerciseEvent event,
    Emitter<HealthState> emit,
  ) async {
    final result = await _completeExercise(event.planId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (plan) => emit(state.copyWith(exercisePlan: plan)),
    );
  }
}
