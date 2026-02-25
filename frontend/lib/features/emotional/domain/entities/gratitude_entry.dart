/// 感恩日记条目
class GratitudeEntry {
  const GratitudeEntry({
    required this.id,
    required this.content,
    this.feedback,
    required this.createdAt,
  });

  final String id;
  final String content;
  final String? feedback;
  final DateTime createdAt;

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    return GratitudeEntry(
      id: json['id'] as String,
      content: json['content'] as String,
      feedback: json['feedback'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
