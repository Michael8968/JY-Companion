class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  static const String wsUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://localhost:8000/api/v1/chat/ws',
  );

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';

  // Users
  static const String currentUser = '/users/me';
  static const String currentUserProfile = '/users/me/profile';

  // Chat
  static const String conversations = '/chat/conversations';
  static String conversationMessages(String id) =>
      '/chat/conversations/$id/messages';
  static String deleteConversation(String id) => '/chat/conversations/$id';

  // Personas
  static const String personas = '/personas';
  static String personaDetail(String id) => '/personas/$id';
  static const String myBindings = '/personas/me/bindings';
  static String setDefaultBinding(String bindingId) =>
      '/personas/me/bindings/$bindingId/set-default';
  static String personaMemories(String personaId) =>
      '/personas/$personaId/memories';
  static String personaCommitments(String personaId) =>
      '/personas/$personaId/commitments';

  // Academic
  static const String learningRecords = '/academic/learning-records';
  static const String diagnose = '/academic/diagnose';
  static const String errorBook = '/academic/error-book';
  static String reviewError(String errorId) =>
      '/academic/error-book/$errorId/review';
  static const String recommendExercises = '/academic/recommend-exercises';

  // Classroom
  static const String classroomSessions = '/classroom/sessions';
  static String classroomSession(String id) => '/classroom/sessions/$id';
  static String transcribe(String id) => '/classroom/sessions/$id/transcribe';
  static String sessionDoubts(String id) => '/classroom/sessions/$id/doubts';
  static String studyPlan(String id) => '/classroom/sessions/$id/study-plan';
  static const String classroomProfile = '/classroom/profile';

  // Emotional
  static const String emotions = '/emotional/emotions';
  static String interventions(String emotion) =>
      '/emotional/interventions/$emotion';
  static const String gratitude = '/emotional/gratitude';
  static const String emotionalAlerts = '/emotional/alerts';

  // Health
  static const String screenTime = '/health/screen-time';
  static const String reminders = '/health/reminders';
  static const String exercisePlan = '/health/exercise-plan';
  static String completeExercise(String planId) =>
      '/health/exercise-plan/$planId/complete';

  // Creative
  static const String creativeGenerate = '/creative/generate';
  static const String creativeOptimize = '/creative/optimize';
  static const String creativeEvaluate = '/creative/evaluate';
  static const String creativeBrainstorm = '/creative/brainstorm';

  // Career
  static const String goals = '/career/goals';
  static String goalDetail(String id) => '/career/goals/$id';
  static String decomposeGoal(String id) => '/career/goals/$id/decompose';
  static const String learningPath = '/career/learning-path';
  static const String progressReport = '/career/progress-report';

  // Voice
  static const String voiceDialogue = '/voice/dialogue';
  static const String voiceSynthesize = '/voice/synthesize';
  static const String voiceExpressionParams = '/voice/expression-params';

  // Admin
  static const String adminUsers = '/admin/users';
  static String adminUserStatus(String id) => '/admin/users/$id/status';
  static const String adminStats = '/admin/stats';
  static const String adminAlerts = '/admin/alerts';
  static String adminAlertResolve(String id) => '/admin/alerts/$id/resolve';

  // System
  static const String health = '/health';
}
