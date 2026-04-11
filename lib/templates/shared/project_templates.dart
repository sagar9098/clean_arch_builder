/// Builds project-level templates shared by generated features.
library;

/// Produces required base files created by `clean_arch_builder init`.
class ProjectTemplates {
  /// Builds all required project initialization files.
  static Map<String, String> buildProjectFiles() {
    return <String, String>{
      'lib/config/app_config.dart': _buildAppConfigFile(),
      'lib/config/env_config.dart': _buildEnvConfigFile(),
      'lib/config/routes.dart': _buildRoutesFile(),
      'lib/core/error/exceptions.dart': _buildExceptionsFile(),
      'lib/core/error/failure.dart': _buildFailureFile(),
      'lib/core/result/either.dart': _buildEitherFile(),
      'lib/core/network/api_client.dart': _buildApiClientFile(),
      'lib/shared/theme/app_theme.dart': _buildAppThemeFile(),
      'lib/main.dart': _buildMainDartFile(),
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

  static String _buildExceptionsFile() {
    return '''library;

abstract class CustomException implements Exception {
  const CustomException(this.message);
  final String message;
}

class ServerException extends CustomException {
  const ServerException([super.message = 'Server error occurred']);
}

class NetworkException extends CustomException {
  const NetworkException([super.message = 'Network connectivity issue']);
}

class TimeoutException extends CustomException {
  const TimeoutException([super.message = 'Connection timed out']);
}

class UnauthorizedException extends CustomException {
  const UnauthorizedException([super.message = 'Unauthorized request']);
}
''';
  }

  /// Builds the `failure.dart` generated file.
  static String _buildFailureFile() {
    return '''library;

abstract class Failure {
  const Failure(this.message);
  final String message;
  
  @override
  String toString() => message;
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

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failure']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown failure']);
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
import '../error/exceptions.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenProvider tokenProvider,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: <String, String>{'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.addAll(<Interceptor>[
      AuthInterceptor(tokenProvider),
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
        ),
    ]);
  }

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Exception _handleException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(exception.message ?? 'Request timeout');
      case DioExceptionType.badResponse:
        final int statusCode = exception.response?.statusCode ?? 0;
        if (statusCode == 401 || statusCode == 403) {
          return const UnauthorizedException();
        }
        return ServerException('Server error (\$statusCode)');
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled');
      case DioExceptionType.unknown:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return NetworkException(exception.message ?? 'Network failure');
    }
  }
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
''';
  }

  static String _buildMainDartFile() {
    return '''import 'package:flutter/material.dart';

import 'config/routes.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection here
  // await initDependencies();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Architecture App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.initial,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
''';
  }

  static String _buildRoutesFile() {
    return '''library;

import 'package:flutter/material.dart';

class AppRoutes {
  const AppRoutes._();

  static const String initial = '/';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute<dynamic>(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Clean Architecture App')),
          ),
        );
      default:
        return null;
    }
  }
}
''';
  }

  static String _buildAppThemeFile() {
    return '''library;

import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }
}
''';
  }
}
