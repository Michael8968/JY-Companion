import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_conversation_model.freezed.dart';
part 'create_conversation_model.g.dart';

@freezed
class CreateConversationModel with _$CreateConversationModel {
  const factory CreateConversationModel({
    required String agentType,
    String? personaId,
    String? title,
  }) = _CreateConversationModel;

  factory CreateConversationModel.fromJson(Map<String, dynamic> json) =>
      _$CreateConversationModelFromJson(json);
}
