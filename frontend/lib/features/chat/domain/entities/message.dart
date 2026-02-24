import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String role,
    required String contentType,
    required String content,
    String? emotionLabel,
    String? intentLabel,
    int? tokenCount,
    required DateTime createdAt,
  }) = _Message;
}
