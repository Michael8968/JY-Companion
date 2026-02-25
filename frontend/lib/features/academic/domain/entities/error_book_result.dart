import 'error_record.dart';

/// 错题本列表结果（领域层）
class ErrorBookResult {
  const ErrorBookResult({
    required this.errors,
    required this.total,
    required this.page,
    required this.size,
  });

  final List<ErrorRecord> errors;
  final int total;
  final int page;
  final int size;
}
