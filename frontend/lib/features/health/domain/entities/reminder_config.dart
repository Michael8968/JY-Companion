/// 提醒配置
class ReminderConfig {
  const ReminderConfig({
    required this.id,
    required this.reminderIntervalMinutes,
    required this.forcedBreakMinutes,
    required this.breakDurationMinutes,
    required this.eyeRestEnabled,
    required this.exerciseEnabled,
    required this.postureEnabled,
  });

  final String id;
  final int reminderIntervalMinutes;
  final int forcedBreakMinutes;
  final int breakDurationMinutes;
  final bool eyeRestEnabled;
  final bool exerciseEnabled;
  final bool postureEnabled;

  factory ReminderConfig.fromJson(Map<String, dynamic> json) {
    return ReminderConfig(
      id: json['id'] as String,
      reminderIntervalMinutes:
          json['reminder_interval_minutes'] as int? ?? 40,
      forcedBreakMinutes: json['forced_break_minutes'] as int? ?? 40,
      breakDurationMinutes: json['break_duration_minutes'] as int? ?? 5,
      eyeRestEnabled: json['eye_rest_enabled'] as bool? ?? true,
      exerciseEnabled: json['exercise_enabled'] as bool? ?? true,
      postureEnabled: json['posture_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'reminder_interval_minutes': reminderIntervalMinutes,
        'forced_break_minutes': forcedBreakMinutes,
        'break_duration_minutes': breakDurationMinutes,
        'eye_rest_enabled': eyeRestEnabled,
        'exercise_enabled': exerciseEnabled,
        'posture_enabled': postureEnabled,
      };
}
