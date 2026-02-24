import 'package:freezed_annotation/freezed_annotation.dart';

part 'ws_message_model.freezed.dart';
part 'ws_message_model.g.dart';

/// Message sent from client to server via WebSocket
@freezed
abstract class WsIncomingMessage with _$WsIncomingMessage {
  const factory WsIncomingMessage({
    required String type,
    String? conversationId,
    String? content,
    @Default('text') String? contentType,
  }) = _WsIncomingMessage;

  factory WsIncomingMessage.fromJson(Map<String, dynamic> json) =>
      _$WsIncomingMessageFromJson(json);

  /// Create a chat message to send
  static WsIncomingMessage chatMessage({
    required String conversationId,
    required String content,
    String contentType = 'text',
  }) =>
      WsIncomingMessage(
        type: 'message',
        conversationId: conversationId,
        content: content,
        contentType: contentType,
      );

  /// Create a ping message
  static WsIncomingMessage ping() =>
      const WsIncomingMessage(type: 'ping');
}

/// Message received from server via WebSocket
@freezed
abstract class WsOutgoingMessage with _$WsOutgoingMessage {
  const factory WsOutgoingMessage({
    required String type,
    Map<String, dynamic>? data,
  }) = _WsOutgoingMessage;

  factory WsOutgoingMessage.fromJson(Map<String, dynamic> json) =>
      _$WsOutgoingMessageFromJson(json);
}

/// WebSocket event types
class WsEventType {
  WsEventType._();

  static const String connected = 'connected';
  static const String pong = 'pong';
  static const String streamStart = 'stream_start';
  static const String streamChunk = 'stream_chunk';
  static const String streamEnd = 'stream_end';
  static const String error = 'error';
}
