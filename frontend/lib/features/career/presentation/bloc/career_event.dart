sealed class CareerEvent {
  const CareerEvent();
}

class CareerLoadEvent extends CareerEvent {
  const CareerLoadEvent();
}

class CareerCreateGoalEvent extends CareerEvent {
  const CareerCreateGoalEvent({
    required this.title,
    this.description,
    this.priority,
    this.deadline,
    this.estimatedHours,
  });
  final String title;
  final String? description;
  final String? priority;
  final String? deadline;
  final double? estimatedHours;
}

class CareerUpdateGoalEvent extends CareerEvent {
  const CareerUpdateGoalEvent({
    required this.goalId,
    this.progressPercent,
    this.status,
  });
  final String goalId;
  final double? progressPercent;
  final String? status;
}

class CareerLoadReportsEvent extends CareerEvent {
  const CareerLoadReportsEvent();
}

class CareerGenerateReportEvent extends CareerEvent {
  const CareerGenerateReportEvent({
    required this.periodStart,
    required this.periodEnd,
  });
  final String periodStart;
  final String periodEnd;
}
