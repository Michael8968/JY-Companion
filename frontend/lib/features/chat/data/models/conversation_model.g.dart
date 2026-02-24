// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    _ConversationModel(
      id: json['id'] as String,
      agentType: json['agent_type'] as String,
      personaId: json['persona_id'] as String?,
      title: json['title'] as String?,
      status: json['status'] as String,
      messageCount: (json['message_count'] as num).toInt(),
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ConversationModelToJson(_ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'agent_type': instance.agentType,
      'persona_id': instance.personaId,
      'title': instance.title,
      'status': instance.status,
      'message_count': instance.messageCount,
      'last_message_at': instance.lastMessageAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
