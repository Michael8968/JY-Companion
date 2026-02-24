import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'api_interceptors.dart';
import 'token_manager.dart';

@module
abstract class NetworkModule {
  @singleton
  Dio dio(TokenManager tokenManager) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(tokenManager),
      ErrorInterceptor(),
      if (kDebugMode) LoggingInterceptor(),
    ]);

    return dio;
  }
}
