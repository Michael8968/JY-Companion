class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = '网络连接失败']);

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = '未授权']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = '缓存异常']);

  @override
  String toString() => 'CacheException: $message';
}
