import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../error/exceptions.dart';
import 'token_manager.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AuthInterceptor(this._tokenManager);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final publicPaths = ['/auth/login', '/auth/register', '/auth/refresh'];
    if (publicPaths.any((path) => options.path.contains(path))) {
      return handler.next(options);
    }

    try {
      final token = await _tokenManager.getValidAccessToken();
      options.headers['Authorization'] = 'Bearer $token';
    } on UnauthorizedException {
      // Let the request proceed without token, server will return 401
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _tokenManager.clearTokens();
    }
    handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException('请求超时'),
          type: err.type,
        ),
      );
      return;
    }

    if (err.type == DioExceptionType.connectionError) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(),
          type: err.type,
        ),
      );
      return;
    }

    if (response != null) {
      final statusCode = response.statusCode ?? 500;
      final data = response.data;
      final message = data is Map<String, dynamic>
          ? (data['detail'] as String? ?? '请求失败')
          : '请求失败';

      if (statusCode == 401) {
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: UnauthorizedException(message),
            response: response,
            type: err.type,
          ),
        );
        return;
      }

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: ServerException(message, statusCode: statusCode),
          response: response,
          type: err.type,
        ),
      );
      return;
    }

    handler.next(err);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('→ ${options.method} ${options.uri}');
      if (options.data != null) {
        debugPrint('  Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✕ ${err.response?.statusCode} ${err.requestOptions.uri}');
      debugPrint('  Error: ${err.message}');
    }
    handler.next(err);
  }
}
