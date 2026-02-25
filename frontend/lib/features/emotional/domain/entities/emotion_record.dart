/// 情绪记录实体
class EmotionRecord {
  const EmotionRecord({
    required this.id,
    required this.emotionLabel,
    required this.valence,
    required this.arousal,
    required this.confidence,
    required this.source,
    this.rawScores,
    required this.createdAt,
  });

  final String id;
  final String emotionLabel;
  final double valence;
  final double arousal;
  final double confidence;
  final String source;
  final Map<String, dynamic>? rawScores;
  final DateTime createdAt;

  String get emotionDisplay {
    switch (emotionLabel) {
      case 'happy':
        return '开心';
      case 'anxious':
        return '焦虑';
      case 'depressed':
        return '低落';
      case 'calm':
        return '平静';
      case 'angry':
        return '生气';
      case 'sad':
        return '难过';
      case 'fearful':
        return '害怕';
      default:
        return emotionLabel;
    }
  }

  factory EmotionRecord.fromJson(Map<String, dynamic> json) {
    return EmotionRecord(
      id: json['id'] as String,
      emotionLabel: json['emotion_label'] as String? ?? 'calm',
      valence: (json['valence'] as num?)?.toDouble() ?? 0,
      arousal: (json['arousal'] as num?)?.toDouble() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      source: json['source'] as String? ?? 'text',
      rawScores: json['raw_scores'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
