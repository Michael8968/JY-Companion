import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/persona_binding_model.dart';
import '../models/persona_model.dart';

@injectable
class PersonaRemoteDataSource {
  final Dio _dio;

  PersonaRemoteDataSource(this._dio);

  Future<List<PersonaModel>> listPersonas() async {
    try {
      final response = await _dio.get(ApiConstants.personas);
      final data = response.data as List<dynamic>;
      return data
          .map((e) => PersonaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PersonaBindingModel> bindPersona(
    String personaId, {
    String? nickname,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.myBindings,
        data: {
          'persona_id': personaId,
          if (nickname != null) 'nickname': nickname,
        },
      );
      return PersonaBindingModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<PersonaBindingModel>> listMyBindings() async {
    try {
      final response = await _dio.get(ApiConstants.myBindings);
      final data = response.data as List<dynamic>;
      return data
          .map(
            (e) => PersonaBindingModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
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
