import 'package:freezed_annotation/freezed_annotation.dart';

part 'persona_model.freezed.dart';
part 'persona_model.g.dart';

@freezed
abstract class PersonaModel with _$PersonaModel {
  const factory PersonaModel({
    required String id,
    required String name,
    required String displayName,
    String? avatarUrl,
    String? description,
    Map<String, dynamic>? personalityTraits,
    String? speakingStyle,
    String? tone,
    String? catchphrase,
    String? vocabularyLevel,
    String? emojiUsage,
    String? humorLevel,
    String? formality,
    String? empathyLevel,
    Map<String, dynamic>? knowledgeDomains,
    Map<String, dynamic>? preferredAgentTypes,
    String? voiceStyle,
    String? voiceSpeed,
    String? animationSet,
    String? responseLength,
    String? encouragementStyle,
    String? teachingApproach,
    required bool isPreset,
    required bool isActive,
    required int version,
    required DateTime createdAt,
  }) = _PersonaModel;

  factory PersonaModel.fromJson(Map<String, dynamic> json) =>
      _$PersonaModelFromJson(json);
}
