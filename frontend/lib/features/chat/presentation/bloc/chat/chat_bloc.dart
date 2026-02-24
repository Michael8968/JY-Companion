import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/datasources/chat_ws_data_source.dart';
import '../../../data/models/ws_message_model.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/usecases/get_messages_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatWsDataSource _wsDataSource;
  final GetMessagesUseCase _getMessagesUseCase;

  StreamSubscription<WsOutgoingMessage>? _wsSubscription;

  ChatBloc(this._wsDataSource, this._getMessagesUseCase)
      : super(const ChatState()) {
    on<ChatEvent>(_onEvent);
  }

  Future<void> _onEvent(ChatEvent event, Emitter<ChatState> emit) async {
    await event.when(
      enterChat: (id) => _onEnterChat(id, emit),
      leaveChat: () => _onLeaveChat(emit),
      sendMessage: (content) => _onSendMessage(content, emit),
      loadMoreMessages: () => _onLoadMoreMessages(emit),
      wsMessageReceived: (message) async => _onWsMessageReceived(message, emit),
      wsConnectionChanged: (connected) async =>
          emit(state.copyWith(wsConnected: connected)),
    );
  }

  Future<void> _onEnterChat(
    String conversationId,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(
      conversationId: conversationId,
      messages: [],
      currentPage: 1,
      isLoadingHistory: true,
      errorMessage: null,
    ));

    // Connect WebSocket
    await _wsDataSource.connect();
    _wsSubscription?.cancel();
    _wsSubscription = _wsDataSource.messageStream.listen(
      (message) => add(ChatEvent.wsMessageReceived(message)),
    );

    // Load initial messages
    final result = await _getMessagesUseCase(conversationId);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingHistory: false,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        isLoadingHistory: false,
        messages: data.messages.reversed.toList(),
        totalMessages: data.total,
        hasMoreMessages: data.messages.length < data.total,
      )),
    );
  }

  Future<void> _onLeaveChat(Emitter<ChatState> emit) async {
    _wsSubscription?.cancel();
    _wsSubscription = null;
    await _wsDataSource.disconnect();
    emit(const ChatState());
  }

  Future<void> _onSendMessage(
    String content,
    Emitter<ChatState> emit,
  ) async {
    if (state.conversationId == null || content.trim().isEmpty) return;

    // Add user message locally
    final userMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      contentType: 'text',
      content: content,
      createdAt: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      errorMessage: null,
    ));

    // Send via WebSocket
    _wsDataSource.sendChatMessage(
      conversationId: state.conversationId!,
      content: content,
    );
  }

  Future<void> _onLoadMoreMessages(Emitter<ChatState> emit) async {
    if (state.isLoadingHistory || !state.hasMoreMessages) return;
    if (state.conversationId == null) return;

    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingHistory: true));

    final result = await _getMessagesUseCase(
      state.conversationId!,
      page: nextPage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingHistory: false,
        errorMessage: failure.message,
      )),
      (data) {
        final allMessages = [
          ...data.messages.reversed,
          ...state.messages,
        ];
        emit(state.copyWith(
          isLoadingHistory: false,
          messages: allMessages,
          currentPage: nextPage,
          hasMoreMessages: allMessages.length < data.total,
        ));
      },
    );
  }

  void _onWsMessageReceived(
    WsOutgoingMessage message,
    Emitter<ChatState> emit,
  ) {
    switch (message.type) {
      case WsEventType.connected:
        emit(state.copyWith(wsConnected: true));
        break;

      case WsEventType.streamStart:
        emit(state.copyWith(
          isStreaming: true,
          isSending: false,
          streamingContent: '',
        ));
        break;

      case WsEventType.streamChunk:
        final content = message.data?['content'] as String? ?? '';
        emit(state.copyWith(
          streamingContent: state.streamingContent + content,
        ));
        break;

      case WsEventType.streamEnd:
        final finalMessage = Message(
          id: message.data?['message_id'] as String? ??
              'msg_${DateTime.now().millisecondsSinceEpoch}',
          role: 'assistant',
          contentType: 'text',
          content: state.streamingContent,
          emotionLabel: message.data?['emotion_label'] as String?,
          intentLabel: message.data?['intent_label'] as String?,
          createdAt: DateTime.now(),
        );
        emit(state.copyWith(
          isStreaming: false,
          streamingContent: '',
          messages: [...state.messages, finalMessage],
        ));
        break;

      case WsEventType.error:
        final errorMsg = message.data?['message'] as String? ?? '发生错误';
        emit(state.copyWith(
          isStreaming: false,
          isSending: false,
          errorMessage: errorMsg,
        ));
        break;

      case WsEventType.pong:
        // Heartbeat response, no action needed
        break;
    }
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    _wsDataSource.dispose();
    return super.close();
  }
}
