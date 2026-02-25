import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/crisis_alert_summary.dart';
import '../../domain/entities/platform_stats.dart';
import '../../domain/entities/user_summary.dart';

@injectable
class AdminRemoteDataSource {
  AdminRemoteDataSource(this._dio);
  final Dio _dio;

  Future<PlatformStats> getStats() async {
    try {
      final response = await _dio.get(ApiConstants.adminStats);
      return PlatformStats.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<({List<UserSummary> users, int total})> getUsers({
    int page = 1,
    int size = 20,
    String? role,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminUsers,
        queryParameters: {
          'page': page,
          'size': size,
          if (role != null && role.isNotEmpty) 'role': role,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['users'] as List<dynamic>? ?? [];
      return (
        users: list
            .map((e) => UserSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: data['total'] as int? ?? 0,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _dio.put(
        ApiConstants.adminUserStatus(userId),
        data: {'is_active': isActive},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<({List<CrisisAlertSummary> alerts, int total})> getAlerts({
    int page = 1,
    int size = 20,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminAlerts,
        queryParameters: {
          'page': page,
          'size': size,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['alerts'] as List<dynamic>? ?? [];
      return (
        alerts: list
            .map((e) => CrisisAlertSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: data['total'] as int? ?? 0,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resolveAlert(String alertId, {String? notes}) async {
    try {
      await _dio.put(
        ApiConstants.adminAlertResolve(alertId),
        queryParameters: notes != null && notes.isNotEmpty ? {'notes': notes} : null,
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
