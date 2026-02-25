/// 课堂会话实体
class ClassroomSession {
  const ClassroomSession({
    required this.id,
    required this.title,
    required this.subject,
    this.audioUrl,
    this.durationSeconds,
    required this.status,
    this.summaryOutline,
    this.summaryConcepts,
    this.keyPoints,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String subject;
  final String? audioUrl;
  final int? durationSeconds;
  final String status;
  final Map<String, dynamic>? summaryOutline;
  final Map<String, dynamic>? summaryConcepts;
  final Map<String, dynamic>? keyPoints;
  final DateTime createdAt;

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing =>
      status == 'uploading' || status == 'transcribing' || status == 'summarizing';

  factory ClassroomSession.fromJson(Map<String, dynamic> json) {
    return ClassroomSession(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      audioUrl: json['audio_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      status: json['status'] as String? ?? 'uploading',
      summaryOutline: json['summary_outline'] as Map<String, dynamic>?,
      summaryConcepts: json['summary_concepts'] as Map<String, dynamic>?,
      keyPoints: json['key_points'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
