import '../../domain/entities/error_record.dart';

class ErrorBookResponse {
  const ErrorBookResponse({
    required this.errors,
    required this.total,
    required this.page,
    required this.size,
  });

  final List<ErrorRecord> errors;
  final int total;
  final int page;
  final int size;

  factory ErrorBookResponse.fromJson(Map<String, dynamic> json) {
    final list = json['errors'] as List<dynamic>? ?? [];
    return ErrorBookResponse(
      errors: list
          .map((e) => ErrorRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 20,
    );
  }
}
