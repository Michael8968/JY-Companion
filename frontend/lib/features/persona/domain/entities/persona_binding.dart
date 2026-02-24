import 'package:freezed_annotation/freezed_annotation.dart';

part 'persona_binding.freezed.dart';

@freezed
class PersonaBinding with _$PersonaBinding {
  const factory PersonaBinding({
    required String id,
    required String userId,
    required String personaId,
    String? nickname,
    required bool isActive,
    required bool isDefault,
    required int interactionCount,
    required DateTime createdAt,
  }) = _PersonaBinding;
}
