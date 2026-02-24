import 'package:freezed_annotation/freezed_annotation.dart';

import 'message_model.dart';

part 'message_list_model.freezed.dart';
part 'message_list_model.g.dart';

@freezed
abstract class MessageListModel with _$MessageListModel {
  const factory MessageListModel({
    required List<MessageModel> messages,
    required int total,
    required int page,
    required int size,
  }) = _MessageListModel;

  factory MessageListModel.fromJson(Map<String, dynamic> json) =>
      _$MessageListModelFromJson(json);
}
