import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String role,
    required String contentType,
    required String content,
    String? emotionLabel,
    String? intentLabel,
    int? tokenCount,
    required DateTime createdAt,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
