import 'package:freezed_annotation/freezed_annotation.dart';

part 'persona.freezed.dart';

@freezed
abstract class Persona with _$Persona {
  const factory Persona({
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
    String? responseLength,
    String? encouragementStyle,
    String? teachingApproach,
    required bool isPreset,
    required bool isActive,
    required int version,
    required DateTime createdAt,
  }) = _Persona;
}
