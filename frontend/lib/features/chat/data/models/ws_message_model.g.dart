// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WsIncomingMessage _$WsIncomingMessageFromJson(Map<String, dynamic> json) =>
    _WsIncomingMessage(
      type: json['type'] as String,
      conversationId: json['conversation_id'] as String?,
      content: json['content'] as String?,
      contentType: json['content_type'] as String? ?? 'text',
    );

Map<String, dynamic> _$WsIncomingMessageToJson(_WsIncomingMessage instance) =>
    <String, dynamic>{
      'type': instance.type,
      'conversation_id': instance.conversationId,
      'content': instance.content,
      'content_type': instance.contentType,
    };

_WsOutgoingMessage _$WsOutgoingMessageFromJson(Map<String, dynamic> json) =>
    _WsOutgoingMessage(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$WsOutgoingMessageToJson(_WsOutgoingMessage instance) =>
    <String, dynamic>{
      'type': instance.type,
      'data': instance.data,
    };
