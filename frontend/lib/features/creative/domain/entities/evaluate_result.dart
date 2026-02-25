/// 作品评价结果
class EvaluateResult {
  const EvaluateResult({
    required this.evaluation,
    this.genre,
  });

  final String evaluation;
  final String? genre;

  factory EvaluateResult.fromJson(Map<String, dynamic> json) {
    return EvaluateResult(
      evaluation: json['evaluation'] as String? ?? '',
      genre: json['genre'] as String?,
    );
  }
}
