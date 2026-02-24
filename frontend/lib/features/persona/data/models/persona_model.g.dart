// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonaModel _$PersonaModelFromJson(Map<String, dynamic> json) =>
    _PersonaModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      description: json['description'] as String?,
      personalityTraits: json['personality_traits'] as Map<String, dynamic>?,
      speakingStyle: json['speaking_style'] as String?,
      tone: json['tone'] as String?,
      catchphrase: json['catchphrase'] as String?,
      vocabularyLevel: json['vocabulary_level'] as String?,
      emojiUsage: json['emoji_usage'] as String?,
      humorLevel: json['humor_level'] as String?,
      formality: json['formality'] as String?,
      empathyLevel: json['empathy_level'] as String?,
      knowledgeDomains: json['knowledge_domains'] as Map<String, dynamic>?,
      preferredAgentTypes:
          json['preferred_agent_types'] as Map<String, dynamic>?,
      voiceStyle: json['voice_style'] as String?,
      voiceSpeed: json['voice_speed'] as String?,
      animationSet: json['animation_set'] as String?,
      responseLength: json['response_length'] as String?,
      encouragementStyle: json['encouragement_style'] as String?,
      teachingApproach: json['teaching_approach'] as String?,
      isPreset: json['is_preset'] as bool,
      isActive: json['is_active'] as bool,
      version: (json['version'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PersonaModelToJson(_PersonaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'description': instance.description,
      'personality_traits': instance.personalityTraits,
      'speaking_style': instance.speakingStyle,
      'tone': instance.tone,
      'catchphrase': instance.catchphrase,
      'vocabulary_level': instance.vocabularyLevel,
      'emoji_usage': instance.emojiUsage,
      'humor_level': instance.humorLevel,
      'formality': instance.formality,
      'empathy_level': instance.empathyLevel,
      'knowledge_domains': instance.knowledgeDomains,
      'preferred_agent_types': instance.preferredAgentTypes,
      'voice_style': instance.voiceStyle,
      'voice_speed': instance.voiceSpeed,
      'animation_set': instance.animationSet,
      'response_length': instance.responseLength,
      'encouragement_style': instance.encouragementStyle,
      'teaching_approach': instance.teachingApproach,
      'is_preset': instance.isPreset,
      'is_active': instance.isActive,
      'version': instance.version,
      'created_at': instance.createdAt.toIso8601String(),
    };
