// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageModel _$MessageModelFromJson(Map<String, dynamic> json) =>
    _MessageModel(
      id: json['id'] as String,
      role: json['role'] as String,
      contentType: json['content_type'] as String,
      content: json['content'] as String,
      emotionLabel: json['emotion_label'] as String?,
      intentLabel: json['intent_label'] as String?,
      tokenCount: (json['token_count'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'content_type': instance.contentType,
      'content': instance.content,
      'emotion_label': instance.emotionLabel,
      'intent_label': instance.intentLabel,
      'token_count': instance.tokenCount,
      'created_at': instance.createdAt.toIso8601String(),
    };
