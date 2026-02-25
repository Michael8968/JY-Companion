import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/classroom_doubt.dart';
import '../../domain/entities/classroom_session.dart';
import '../../domain/entities/study_plan.dart';

@injectable
class ClassroomRemoteDataSource {
  ClassroomRemoteDataSource(this._dio);
  final Dio _dio;

  Future<ClassroomSession> createSession({
    required String title,
    required String subject,
    String? audioUrl,
    int? durationSeconds,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.classroomSessions,
        data: {
          'title': title,
          'subject': subject,
          if (audioUrl != null) 'audio_url': audioUrl,
          if (durationSeconds != null) 'duration_seconds': durationSeconds,
        },
      );
      return ClassroomSession.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ClassroomSession> transcribeSession(String sessionId) async {
    try {
      final response = await _dio.post(
        ApiConstants.transcribe(sessionId),
      );
      return ClassroomSession.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ClassroomSession> getSession(String sessionId) async {
    try {
      final response = await _dio.get(
        ApiConstants.classroomSession(sessionId),
      );
      return ClassroomSession.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ClassroomDoubt>> getSessionDoubts(String sessionId) async {
    try {
      final response = await _dio.get(
        ApiConstants.sessionDoubts(sessionId),
      );
      final list = response.data as List<dynamic>? ?? [];
      return list
          .map((e) => ClassroomDoubt.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<StudyPlan> generateStudyPlan(String sessionId) async {
    try {
      final response = await _dio.post(
        ApiConstants.studyPlan(sessionId),
      );
      return StudyPlan.fromJson(
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
