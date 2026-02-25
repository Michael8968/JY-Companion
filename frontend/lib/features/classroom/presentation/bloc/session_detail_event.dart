sealed class SessionDetailEvent {
  const SessionDetailEvent();
}

class SessionDetailLoadEvent extends SessionDetailEvent {
  const SessionDetailLoadEvent(this.sessionId);
  final String sessionId;
}

class SessionDetailGenerateStudyPlanEvent extends SessionDetailEvent {
  const SessionDetailGenerateStudyPlanEvent(this.sessionId);
  final String sessionId;
}
