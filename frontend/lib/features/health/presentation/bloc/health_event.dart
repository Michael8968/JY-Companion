sealed class HealthEvent {
  const HealthEvent();
}

class HealthLoadEvent extends HealthEvent {
  const HealthLoadEvent();
}

class HealthUpdateReminderEvent extends HealthEvent {
  const HealthUpdateReminderEvent(this.config);
  final Map<String, dynamic> config;
}

class HealthLoadExercisePlanEvent extends HealthEvent {
  const HealthLoadExercisePlanEvent(this.planType);
  final String planType;
}

class HealthCompleteExerciseEvent extends HealthEvent {
  const HealthCompleteExerciseEvent(this.planId);
  final String planId;
}
