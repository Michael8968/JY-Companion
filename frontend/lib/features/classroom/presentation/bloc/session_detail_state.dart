import '../../domain/entities/classroom_doubt.dart';
import '../../domain/entities/classroom_session.dart';
import '../../domain/entities/study_plan.dart';

class SessionDetailState {
  const SessionDetailState({
    this.session,
    this.doubts,
    this.studyPlan,
    this.isLoading = false,
    this.isLoadingDoubts = false,
    this.isLoadingStudyPlan = false,
    this.errorMessage,
  });

  final ClassroomSession? session;
  final List<ClassroomDoubt>? doubts;
  final StudyPlan? studyPlan;
  final bool isLoading;
  final bool isLoadingDoubts;
  final bool isLoadingStudyPlan;
  final String? errorMessage;

  SessionDetailState copyWith({
    ClassroomSession? session,
    List<ClassroomDoubt>? doubts,
    StudyPlan? studyPlan,
    bool? isLoading,
    bool? isLoadingDoubts,
    bool? isLoadingStudyPlan,
    String? errorMessage,
  }) {
    return SessionDetailState(
      session: session ?? this.session,
      doubts: doubts ?? this.doubts,
      studyPlan: studyPlan ?? this.studyPlan,
      isLoading: isLoading ?? this.isLoading,
      isLoadingDoubts: isLoadingDoubts ?? this.isLoadingDoubts,
      isLoadingStudyPlan: isLoadingStudyPlan ?? this.isLoadingStudyPlan,
      errorMessage: errorMessage,
    );
  }
}
