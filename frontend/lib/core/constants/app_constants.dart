class AppConstants {
  AppConstants._();

  static const String appName = '星澜学伴';
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration wsReconnectBaseDelay = Duration(seconds: 1);
  static const int wsMaxReconnectAttempts = 5;
  static const Duration wsPingInterval = Duration(seconds: 30);
  static const Duration screenTimeReportInterval = Duration(minutes: 5);
  static const int forcedBreakMinutes = 40;
}
