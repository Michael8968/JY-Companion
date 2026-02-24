import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String agentType,
    String? personaId,
    String? title,
    required String status,
    required int messageCount,
    DateTime? lastMessageAt,
    required DateTime createdAt,
  }) = _Conversation;
}
