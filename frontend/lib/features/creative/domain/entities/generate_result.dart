/// 创意生成结果
class GenerateResult {
  const GenerateResult({
    required this.content,
    required this.topic,
    this.style,
  });

  final String content;
  final String topic;
  final String? style;

  factory GenerateResult.fromJson(Map<String, dynamic> json) {
    return GenerateResult(
      content: json['content'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      style: json['style'] as String?,
    );
  }
}
