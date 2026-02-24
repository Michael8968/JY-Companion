import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/conversation_model.dart';
import '../models/create_conversation_model.dart';
import '../models/message_list_model.dart';

@injectable
class ChatRemoteDataSource {
  final Dio _dio;

  ChatRemoteDataSource(this._dio);

  Future<ConversationModel> createConversation(
    CreateConversationModel request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.conversations,
        data: request.toJson(),
      );
      return ConversationModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ConversationModel>> listConversations({
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.conversations,
        queryParameters: {'page': page, 'size': size},
      );
      final data = response.data as List<dynamic>;
      return data
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<MessageListModel> getMessages(
    String conversationId, {
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.conversationMessages(conversationId),
        queryParameters: {'page': page, 'size': size},
      );
      return MessageListModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _dio.delete(ApiConstants.deleteConversation(conversationId));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.error is ServerException) return e.error as ServerException;
    if (e.error is UnauthorizedException) {
      return e.error as UnauthorizedException;
    }
    if (e.error is NetworkException) return e.error as NetworkException;
    return ServerException(
      e.message ?? '请求失败',
      statusCode: e.response?.statusCode,
    );
  }
}
