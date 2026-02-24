// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona_binding_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonaBindingModel _$PersonaBindingModelFromJson(Map<String, dynamic> json) =>
    _PersonaBindingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      personaId: json['persona_id'] as String,
      nickname: json['nickname'] as String?,
      isActive: json['is_active'] as bool,
      isDefault: json['is_default'] as bool,
      interactionCount: (json['interaction_count'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PersonaBindingModelToJson(
        _PersonaBindingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'persona_id': instance.personaId,
      'nickname': instance.nickname,
      'is_active': instance.isActive,
      'is_default': instance.isDefault,
      'interaction_count': instance.interactionCount,
      'created_at': instance.createdAt.toIso8601String(),
    };
