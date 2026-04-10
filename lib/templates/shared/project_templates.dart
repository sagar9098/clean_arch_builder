library;

class ProjectTemplates {
  static Map<String, String> buildProjectFiles() {
    return <String, String>{
      'lib/config/app_config.dart': _buildAppConfigFile(),
      'lib/config/env_config.dart': _buildEnvConfigFile(),
      'lib/core/error/failure.dart': _buildFailureFile(),
      'lib/core/result/either.dart': _buildEitherFile(),
      'lib/core/network/api_client.dart': _buildApiClientFile(),
    };
  }

  static String _buildAppConfigFile() {
    return '''library;

import 'env_config.dart';

class AppConfig {
  const AppConfig._();

  static const String apiVersion = '/v1';

  static String baseUrl() {
    return EnvConfig.isProduction
        ? EnvConfig.productionBaseUrl
        : EnvConfig.developmentBaseUrl;
  }
}
''';
  }

  static String _buildEnvConfigFile() {
    return '''library;

class EnvConfig {
  const EnvConfig._();

  static const bool isProduction = false;
  static const String developmentBaseUrl = 'https://api.dev.example.com';
  static const String productionBaseUrl = 'https://api.example.com';
}
''';
  }

  static String _buildFailureFile() {
    return '''library;

import 'package:dio/dio.dart';

abstract class Failure {
  const Failure(this.message);
  final String message;
  @override
  String toString() {
    return message;
  }
}
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server failure']);
}
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network failure']);
}
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timeout']);
}
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown failure']);
}

Failure mapDioExceptionToFailure(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutFailure(exception.message ?? 'Request timeout');
    case DioExceptionType.badResponse:
      final int statusCode = exception.response?.statusCode ?? 0;
      return ServerFailure('Server error (\$statusCode)');
    case DioExceptionType.cancel:
      return NetworkFailure('Request was cancelled');
    case DioExceptionType.unknown:
      return NetworkFailure(exception.message ?? 'Network failure');
    case DioExceptionType.badCertificate:
    case DioExceptionType.connectionError:
      return NetworkFailure(exception.message ?? 'Network failure');
  }
}
''';
  }

  static String _buildEitherFile() {
    return '''library;

abstract class Either<L, R> {
  const Either();
  T fold<T>({
    required T Function(L left) onLeft,
    required T Function(R right) onRight,
  });
}
class Left<L, R> extends Either<L, R> {
  const Left(this.value);
  final L value;
  @override
  T fold<T>({
    required T Function(L left) onLeft,
    required T Function(R right) onRight,
  }) {
    return onLeft(value);
  }
}
class Right<L, R> extends Either<L, R> {
  const Right(this.value);
  final R value;
  @override
  T fold<T>({
    required T Function(L left) onLeft,
    required T Function(R right) onRight,
  }) {
    return onRight(value);
  }
}
''';
  }

  static String _buildApiClientFile() {
    return '''library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenProvider tokenProvider,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: <String, String>{'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(AuthInterceptor(tokenProvider));
    dio.interceptors.add(ErrorInterceptor());
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }
  }

  final Dio dio;
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenProvider);

  final TokenProvider _tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer \$token';
    }
    handler.next(options);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
''';
  }
}
