import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/models/ws_message_model.dart';

part 'chat_event.freezed.dart';

@freezed
abstract class ChatEvent with _$ChatEvent {
  const factory ChatEvent.enterChat(String conversationId) = _EnterChat;
  const factory ChatEvent.leaveChat() = _LeaveChat;
  const factory ChatEvent.sendMessage(String content) = _SendMessage;
  const factory ChatEvent.loadMoreMessages() = _LoadMoreMessages;
  const factory ChatEvent.wsMessageReceived(WsOutgoingMessage message) =
      _WsMessageReceived;
  const factory ChatEvent.wsConnectionChanged(bool connected) =
      _WsConnectionChanged;
}
