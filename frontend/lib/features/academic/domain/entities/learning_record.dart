import 'subject.dart';

class LearningRecord {
  const LearningRecord({
    required this.id,
    required this.subject,
    required this.question,
    this.answer,
    this.knowledgePoints,
    required this.difficulty,
    this.isCorrect,
    required this.createdAt,
  });

  final String id;
  final Subject subject;
  final String question;
  final String? answer;
  final Map<String, dynamic>? knowledgePoints;
  final String difficulty;
  final bool? isCorrect;
  final DateTime createdAt;

  factory LearningRecord.fromJson(Map<String, dynamic> json) {
    return LearningRecord(
      id: json['id'] as String,
      subject: Subject.fromString(json['subject'] as String?) ?? Subject.math,
      question: json['question'] as String,
      answer: json['answer'] as String?,
      knowledgePoints: json['knowledge_points'] as Map<String, dynamic>?,
      difficulty: json['difficulty'] as String? ?? 'medium',
      isCorrect: json['is_correct'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
