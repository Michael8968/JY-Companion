/// 进度报告
class ProgressReport {
  const ProgressReport({
    required this.id,
    required this.reportType,
    required this.periodStart,
    required this.periodEnd,
    this.completionStats,
    this.deviationAnalysis,
    this.recommendations,
    this.content,
    required this.createdAt,
  });

  final String id;
  final String reportType;
  final String periodStart;
  final String periodEnd;
  final Map<String, dynamic>? completionStats;
  final Map<String, dynamic>? deviationAnalysis;
  final Map<String, dynamic>? recommendations;
  final String? content;
  final DateTime createdAt;

  factory ProgressReport.fromJson(Map<String, dynamic> json) {
    return ProgressReport(
      id: json['id'] as String,
      reportType: json['report_type'] as String? ?? 'weekly',
      periodStart: json['period_start'] as String,
      periodEnd: json['period_end'] as String,
      completionStats: json['completion_stats'] as Map<String, dynamic>?,
      deviationAnalysis:
          json['deviation_analysis'] as Map<String, dynamic>?,
      recommendations: json['recommendations'] as Map<String, dynamic>?,
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
