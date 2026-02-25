import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/exercise_plan.dart';
import '../../domain/entities/reminder_config.dart';
import '../../domain/entities/screen_time_record.dart';

@injectable
class HealthRemoteDataSource {
  HealthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<ScreenTimeRecord>> getScreenTimeHistory({int limit = 50}) async {
    try {
      final response = await _dio.get(
        ApiConstants.screenTime,
        queryParameters: {'limit': limit},
      );
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => ScreenTimeRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ReminderConfig> getReminderConfig() async {
    try {
      final response = await _dio.get(ApiConstants.reminders);
      return ReminderConfig.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ReminderConfig> updateReminderConfig(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.reminders,
        data: body,
      );
      return ReminderConfig.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ExercisePlan> getExercisePlan({String planType = 'stretch'}) async {
    try {
      final response = await _dio.get(
        ApiConstants.exercisePlan,
        queryParameters: {'plan_type': planType},
      );
      return ExercisePlan.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ExercisePlan> completeExercise(String planId) async {
    try {
      final response = await _dio.post(
        ApiConstants.completeExercise(planId),
      );
      return ExercisePlan.fromJson(
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
