import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';

@injectable
class CreativeRemoteDataSource {
  CreativeRemoteDataSource(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> generate({
    required String topic,
    String? style,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.creativeGenerate,
        data: {
          'topic': topic,
          if (style != null && style.isNotEmpty) 'style': style,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> evaluate({
    required String text,
    String? genre,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.creativeEvaluate,
        data: {
          'text': text,
          if (genre != null && genre.isNotEmpty) 'genre': genre,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> brainstorm({
    required String context,
    String? stuckPoint,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.creativeBrainstorm,
        data: {
          'context': context,
          if (stuckPoint != null && stuckPoint.isNotEmpty) 'stuck_point': stuckPoint,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> optimize({required String text}) async {
    try {
      final response = await _dio.post(
        ApiConstants.creativeOptimize,
        data: {'text': text},
      );
      return response.data as Map<String, dynamic>;
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
