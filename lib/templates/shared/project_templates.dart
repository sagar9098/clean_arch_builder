/// Builds project-level templates shared by generated features.
library;

/// Produces required base files created by `clean_arch_builder init`.
class ProjectTemplates {
  /// Builds all required project initialization files.
  static Map<String, String> buildProjectFiles() {
    return <String, String>{
      'lib/config/app_config.dart': _buildAppConfigFile(),
      'lib/config/env_config.dart': _buildEnvConfigFile(),
      'lib/core/error/failure.dart': _buildFailureFile(),
      'lib/core/result/either.dart': _buildEitherFile(),
      'lib/core/network/api_client.dart': _buildApiClientFile(),
    };
  }

  /// Builds the `app_config.dart` generated file.
  static String _buildAppConfigFile() {
    return '''library;

import 'env_config.dart';

class AppConfig {
  const AppConfig._();

  static const String apiVersion = '/v1';

  static String baseUrl() {
    // Resolves active base url
    return EnvConfig.isProduction
        ? EnvConfig.productionBaseUrl
        : EnvConfig.developmentBaseUrl;
  }
}
''';
  }

  /// Builds the `env_config.dart` generated file.
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

  /// Builds the `failure.dart` generated file.
  static String _buildFailureFile() {
    return '''library;

import 'package:dio/dio.dart';

abstract class Failure {
  const Failure(this.message);
  final String message;
  @override
  String toString() {
    // Returns readable failure message
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
  // Maps dio exception to failure
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
      return UnknownFailure(exception.message ?? 'Unknown failure');
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return NetworkFailure(exception.message ?? 'Network failure');
  }
}
''';
  }

  /// Builds the `either.dart` generated file.
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
    // Resolves left branch
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
    // Resolves right branch
    return onRight(value);
  }
}
''';
  }

  /// Builds the `api_client.dart` generated file.
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
    // Adds auth interceptor
    dio.interceptors.add(AuthInterceptor(tokenProvider));
    // Adds error interceptor
    dio.interceptors.add(ErrorInterceptor());
    if (kDebugMode) {
      // Adds debug logging interceptor
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
    // Injects bearer token when available
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
    // Propagates dio error through pipeline
    handler.next(err);
  }
}
''';
  }
}
