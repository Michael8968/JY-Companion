import '../../domain/entities/goal.dart';
import '../../domain/entities/progress_report.dart';

class CareerState {
  const CareerState({
    this.goals = const [],
    this.reports = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Goal> goals;
  final List<ProgressReport> reports;
  final bool isLoading;
  final String? errorMessage;

  CareerState copyWith({
    List<Goal>? goals,
    List<ProgressReport>? reports,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CareerState(
      goals: goals ?? this.goals,
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
