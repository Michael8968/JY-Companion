import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/learning_path.dart';
import '../../domain/entities/progress_report.dart';

@injectable
class CareerRemoteDataSource {
  CareerRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<Goal>> getGoals({String? status}) async {
    try {
      final response = await _dio.get(
        ApiConstants.goals,
        queryParameters: status != null ? {'status': status} : null,
      );
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Goal> createGoal({
    required String title,
    String? description,
    String? parentId,
    String? priority,
    String? deadline,
    double? estimatedHours,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.goals,
        data: {
          'title': title,
          if (description != null) 'description': description,
          if (parentId != null) 'parent_id': parentId,
          if (priority != null) 'priority': priority,
          if (deadline != null) 'deadline': deadline,
          if (estimatedHours != null) 'estimated_hours': estimatedHours,
        },
      );
      return Goal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Goal> updateGoal(
    String goalId, {
    double? progressPercent,
    String? status,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.goalDetail(goalId),
        data: {
          if (progressPercent != null) 'progress_percent': progressPercent,
          if (status != null) 'status': status,
        },
      );
      return Goal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<LearningPath>> getLearningPaths() async {
    try {
      final response = await _dio.get(ApiConstants.learningPath);
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => LearningPath.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<LearningPath> generateLearningPath({
    required List<String> interests,
    required String goalDescription,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.learningPath,
        data: {
          'interests': interests,
          'goal_description': goalDescription,
        },
      );
      return LearningPath.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ProgressReport>> getProgressReports() async {
    try {
      final response = await _dio.get(ApiConstants.progressReport);
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => ProgressReport.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ProgressReport> generateProgressReport({
    required String periodStart,
    required String periodEnd,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.progressReport,
        data: {
          'period_start': periodStart,
          'period_end': periodEnd,
        },
      );
      return ProgressReport.fromJson(
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
