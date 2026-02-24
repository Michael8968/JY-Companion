import 'package:freezed_annotation/freezed_annotation.dart';

part 'persona_binding_model.freezed.dart';
part 'persona_binding_model.g.dart';

@freezed
class PersonaBindingModel with _$PersonaBindingModel {
  const factory PersonaBindingModel({
    required String id,
    required String userId,
    required String personaId,
    String? nickname,
    required bool isActive,
    required bool isDefault,
    required int interactionCount,
    required DateTime createdAt,
  }) = _PersonaBindingModel;

  factory PersonaBindingModel.fromJson(Map<String, dynamic> json) =>
      _$PersonaBindingModelFromJson(json);
}
