import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../error/exceptions.dart';

@singleton
class TokenManager {
  Box? _authBox;

  Future<void> init() async {
    _authBox = await Hive.openBox(StorageKeys.authBox);
  }

  Box get _box {
    if (_authBox == null || !_authBox!.isOpen) {
      throw const CacheException('Auth storage not initialized');
    }
    return _authBox!;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _box.put(StorageKeys.accessToken, accessToken);
    await _box.put(StorageKeys.refreshToken, refreshToken);
  }

  String? get accessToken => _box.get(StorageKeys.accessToken) as String?;

  String? get refreshToken => _box.get(StorageKeys.refreshToken) as String?;

  bool get hasTokens => accessToken != null && refreshToken != null;

  bool get isAccessTokenExpired {
    final token = accessToken;
    if (token == null) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = json.decode(payload) as Map<String, dynamic>;
      final exp = data['exp'] as int?;
      if (exp == null) return true;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // Consider expired 60 seconds before actual expiry
      return DateTime.now().isAfter(expiry.subtract(const Duration(seconds: 60)));
    } catch (_) {
      return true;
    }
  }

  Future<String> getValidAccessToken() async {
    if (!hasTokens) {
      throw const UnauthorizedException('No tokens stored');
    }

    if (!isAccessTokenExpired) {
      return accessToken!;
    }

    // Attempt token refresh
    return _refreshAccessToken();
  }

  Future<String> _refreshAccessToken() async {
    final refresh = refreshToken;
    if (refresh == null) {
      throw const UnauthorizedException('No refresh token');
    }

    try {
      // Use a separate Dio instance to avoid interceptor loops
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.post(
        ApiConstants.refresh,
        data: {'refresh_token': refresh},
      );

      final data = response.data as Map<String, dynamic>;
      final newAccess = data['access_token'] as String;
      final newRefresh = data['refresh_token'] as String;

      await saveTokens(accessToken: newAccess, refreshToken: newRefresh);
      return newAccess;
    } on DioException {
      await clearTokens();
      throw const UnauthorizedException('Token refresh failed');
    }
  }

  Future<void> clearTokens() async {
    await _box.delete(StorageKeys.accessToken);
    await _box.delete(StorageKeys.refreshToken);
    await _box.delete(StorageKeys.currentUserId);
    await _box.delete(StorageKeys.currentUserJson);
  }

  Future<void> saveCurrentUser(Map<String, dynamic> userJson) async {
    await _box.put(StorageKeys.currentUserJson, json.encode(userJson));
  }

  Map<String, dynamic>? get cachedUser {
    final raw = _box.get(StorageKeys.currentUserJson) as String?;
    if (raw == null) return null;
    return json.decode(raw) as Map<String, dynamic>;
  }
}
