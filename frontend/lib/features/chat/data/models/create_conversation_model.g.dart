// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateConversationModel _$CreateConversationModelFromJson(
  Map<String, dynamic> json,
) => _CreateConversationModel(
  agentType: json['agent_type'] as String,
  personaId: json['persona_id'] as String?,
  title: json['title'] as String?,
);

Map<String, dynamic> _$CreateConversationModelToJson(
  _CreateConversationModel instance,
) => <String, dynamic>{
  'agent_type': instance.agentType,
  'persona_id': instance.personaId,
  'title': instance.title,
};
