// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageListModel _$MessageListModelFromJson(Map<String, dynamic> json) =>
    _MessageListModel(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$MessageListModelToJson(_MessageListModel instance) =>
    <String, dynamic>{
      'messages': instance.messages,
      'total': instance.total,
      'page': instance.page,
      'size': instance.size,
    };
