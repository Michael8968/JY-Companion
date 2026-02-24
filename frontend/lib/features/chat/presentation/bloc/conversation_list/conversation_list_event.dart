import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_list_event.freezed.dart';

@freezed
class ConversationListEvent with _$ConversationListEvent {
  const factory ConversationListEvent.load() = _Load;
  const factory ConversationListEvent.refresh() = _Refresh;
  const factory ConversationListEvent.create({
    required String agentType,
    String? personaId,
    String? title,
  }) = _Create;
  const factory ConversationListEvent.delete(String conversationId) = _Delete;
}
