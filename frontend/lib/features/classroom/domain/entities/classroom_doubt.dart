/// 课堂疑问点
class ClassroomDoubt {
  const ClassroomDoubt({
    required this.id,
    required this.timestampStart,
    required this.timestampEnd,
    required this.textExcerpt,
    required this.doubtType,
    required this.importance,
    this.context,
  });

  final String id;
  final double timestampStart;
  final double timestampEnd;
  final String textExcerpt;
  final String doubtType;
  final double importance;
  final String? context;

  String get doubtTypeDisplay {
    switch (doubtType) {
      case 'slow_pace':
        return '语速较慢';
      case 'repetition':
        return '重复讲解';
      case 'student_question':
        return '学生提问';
      default:
        return doubtType;
    }
  }

  factory ClassroomDoubt.fromJson(Map<String, dynamic> json) {
    return ClassroomDoubt(
      id: json['id'] as String,
      timestampStart: (json['timestamp_start'] as num).toDouble(),
      timestampEnd: (json['timestamp_end'] as num).toDouble(),
      textExcerpt: json['text_excerpt'] as String,
      doubtType: json['doubt_type'] as String? ?? 'student_question',
      importance: (json['importance'] as num?)?.toDouble() ?? 0.5,
      context: json['context'] as String?,
    );
  }
}
