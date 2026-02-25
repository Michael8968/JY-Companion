import 'subject.dart';

class ErrorRecord {
  const ErrorRecord({
    required this.id,
    required this.subject,
    required this.question,
    required this.wrongAnswer,
    this.correctAnswer,
    required this.errorType,
    this.errorAnalysis,
    required this.masteryStatus,
    required this.reviewCount,
    this.knowledgePoints,
    required this.createdAt,
  });

  final String id;
  final Subject subject;
  final String question;
  final String wrongAnswer;
  final String? correctAnswer;
  final String errorType;
  final String? errorAnalysis;
  final String masteryStatus;
  final int reviewCount;
  final Map<String, dynamic>? knowledgePoints;
  final DateTime createdAt;

  String get errorTypeDisplay {
    switch (errorType) {
      case 'concept_misunderstanding':
        return '概念误解';
      case 'wrong_approach':
        return '思路偏差';
      case 'misread_question':
        return '审题失误';
      case 'calculation_error':
        return '计算疏忽';
      default:
        return errorType;
    }
  }

  String get masteryStatusDisplay {
    switch (masteryStatus) {
      case 'weak':
        return '待巩固';
      case 'improving':
        return '进步中';
      case 'mastered':
        return '已掌握';
      default:
        return masteryStatus;
    }
  }

  factory ErrorRecord.fromJson(Map<String, dynamic> json) {
    return ErrorRecord(
      id: json['id'] as String,
      subject: Subject.fromString(json['subject'] as String?) ?? Subject.math,
      question: json['question'] as String,
      wrongAnswer: json['wrong_answer'] as String,
      correctAnswer: json['correct_answer'] as String?,
      errorType: json['error_type'] as String? ?? 'concept_misunderstanding',
      errorAnalysis: json['error_analysis'] as String?,
      masteryStatus: json['mastery_status'] as String? ?? 'weak',
      reviewCount: json['review_count'] as int? ?? 0,
      knowledgePoints: json['knowledge_points'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
