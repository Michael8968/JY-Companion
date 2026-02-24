import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/conversation.dart';

part 'conversation_list_state.freezed.dart';

@freezed
class ConversationListState with _$ConversationListState {
  const factory ConversationListState({
    @Default([]) List<Conversation> conversations,
    @Default(false) bool isLoading,
    @Default(false) bool isCreating,
    String? errorMessage,
    String? createdConversationId,
  }) = _ConversationListState;
}
