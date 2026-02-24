import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/message.dart';

part 'chat_state.freezed.dart';

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<Message> messages,
    @Default(false) bool isLoadingHistory,
    @Default(false) bool isSending,
    @Default(false) bool isStreaming,
    @Default('') String streamingContent,
    @Default(true) bool wsConnected,
    @Default(false) bool hasMoreMessages,
    @Default(1) int currentPage,
    @Default(0) int totalMessages,
    String? conversationId,
    String? errorMessage,
  }) = _ChatState;
}
