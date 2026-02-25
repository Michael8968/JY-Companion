import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/emotion_record.dart';
import '../../domain/entities/gratitude_entry.dart';

@injectable
class EmotionalRemoteDataSource {
  EmotionalRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<EmotionRecord>> getEmotionHistory({int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.emotions,
        queryParameters: {'limit': limit},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => EmotionRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<GratitudeEntry>> getGratitudeEntries({int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.gratitude,
        queryParameters: {'limit': limit},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => GratitudeEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<GratitudeEntry> createGratitudeEntry(String content) async {
    try {
      final response = await _dio.post(
        ApiConstants.gratitude,
        data: {'content': content},
      );
      return GratitudeEntry.fromJson(
        response.data as Map<String, dynamic>,
      );
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
    final data = e.response?.data;
    final message = data is Map<String, dynamic>
        ? (data['detail'] as String? ?? '请求失败')
        : '请求失败';
    return ServerException(
      message,
      statusCode: e.response?.statusCode,
    );
  }
}
