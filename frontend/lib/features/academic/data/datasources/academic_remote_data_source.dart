import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/error_record.dart';
import '../../domain/entities/subject.dart';
import '../models/error_book_response.dart';

@injectable
class AcademicRemoteDataSource {
  AcademicRemoteDataSource(this._dio);
  final Dio _dio;

  Future<ErrorBookResponse> getErrorBook({
    Subject? subject,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (subject != null) query['subject'] = subject.value;
      final response = await _dio.get(
        ApiConstants.errorBook,
        queryParameters: query,
      );
      return ErrorBookResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ErrorRecord> reviewError(String errorId) async {
    try {
      final response = await _dio.post(
        ApiConstants.reviewError(errorId),
      );
      return ErrorRecord.fromJson(
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
