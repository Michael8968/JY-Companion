import '../../domain/entities/exercise_plan.dart';
import '../../domain/entities/reminder_config.dart';
import '../../domain/entities/screen_time_record.dart';

class HealthState {
  const HealthState({
    this.screenTimeHistory = const [],
    this.reminderConfig,
    this.exercisePlan,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ScreenTimeRecord> screenTimeHistory;
  final ReminderConfig? reminderConfig;
  final ExercisePlan? exercisePlan;
  final bool isLoading;
  final String? errorMessage;

  HealthState copyWith({
    List<ScreenTimeRecord>? screenTimeHistory,
    ReminderConfig? reminderConfig,
    ExercisePlan? exercisePlan,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HealthState(
      screenTimeHistory: screenTimeHistory ?? this.screenTimeHistory,
      reminderConfig: reminderConfig ?? this.reminderConfig,
      exercisePlan: exercisePlan ?? this.exercisePlan,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
