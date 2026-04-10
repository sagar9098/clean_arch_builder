/// Project-level template builders for reusable app scaffolding.
///
/// This file defines minimal and reusable starter files under `lib/config`,
/// `lib/core`, and `lib/shared` so all generated features can depend on
/// shared foundations.
library;

/// Builds reusable project-scaffold files shared by all features.
class ProjectTemplates {
  /// Builds all project-level base files.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Map where keys are project-relative paths and values are Dart file
  ///   contents.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static Map<String, String> buildProjectFiles() {
    return <String, String>{
      'lib/config/app_config.dart': _buildAppConfigFile(),
      'lib/config/env_config.dart': _buildEnvConfigFile(),
      'lib/config/routes.dart': _buildRoutesFile(),
      'lib/core/error/failure.dart': _buildFailureFile(),
      'lib/core/error/exceptions.dart': _buildExceptionsFile(),
      'lib/core/result/either.dart': _buildEitherFile(),
      'lib/core/network/api_client.dart': _buildApiClientFile(),
      'lib/core/utils/logger.dart': _buildLoggerFile(),
      'lib/core/constants/app_constants.dart': _buildAppConstantsFile(),
      'lib/shared/widgets/custom_button.dart': _buildCustomButtonFile(),
      'lib/shared/widgets/custom_loader.dart': _buildCustomLoaderFile(),
      'lib/shared/theme/app_theme.dart': _buildAppThemeFile(),
      'lib/shared/helpers/validators.dart': _buildValidatorsFile(),
    };
  }

  /// Builds `lib/config/app_config.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for application configuration values.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildAppConfigFile() {
    return '''/// App Configuration
/// Stores shared app configuration values used across all features.
/// Layer: Config
library;

import 'env_config.dart';

/// Central app-level configuration used by network and presentation layers.
class AppConfig {
  /// Creates a non-instantiable configuration namespace.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - This constructor is never used directly.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const AppConfig._();

  /// Human-readable application name.
  static const String appName = 'Clean Architecture App';

  /// Shared API version prefix.
  static const String apiVersion = '/v1';

  /// Active base URL resolved from [EnvConfig].
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Development or production base URL depending on environment.
  ///
  /// Possible errors:
  /// - This getter does not throw under normal usage.
  static String get baseUrl {
    return EnvConfig.isProduction
        ? EnvConfig.productionBaseUrl
        : EnvConfig.developmentBaseUrl;
  }
}
''';
  }

  /// Builds `lib/config/env_config.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for environment selection and endpoints.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildEnvConfigFile() {
    return '''/// Environment Configuration
/// Provides simple development and production environment switches.
/// Layer: Config
library;

/// Defines environment-specific settings used by [AppConfig].
class EnvConfig {
  /// Creates a non-instantiable environment namespace.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - This constructor is never used directly.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const EnvConfig._();

  /// Enables production values when set to `true`.
  static const bool isProduction = false;

  /// Development API base URL.
  static const String developmentBaseUrl = 'https://api.dev.example.com';

  /// Production API base URL.
  static const String productionBaseUrl = 'https://api.example.com';
}
''';
  }

  /// Builds `lib/config/routes.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for lightweight route constants.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildRoutesFile() {
    return '''/// Route Configuration
/// Defines shared route names for app navigation.
/// Layer: Config
library;

/// Central route-name registry.
class AppRoutes {
  /// Creates a non-instantiable routes namespace.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - This constructor is never used directly.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const AppRoutes._();

  /// Root route.
  static const String home = '/';

  /// Generic settings route.
  static const String settings = '/settings';

  /// Simple route map useful for lightweight router setups.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Map of route keys to route paths.
  ///
  /// Possible errors:
  /// - This getter does not throw under normal usage.
  static Map<String, String> get routeMap {
    return <String, String>{
      'home': home,
      'settings': settings,
    };
  }
}
''';
  }

  /// Builds `lib/core/error/failure.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for shared failure models.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildFailureFile() {
    return '''/// Shared Failure Models
/// Defines application failures reused across all features.
/// Layer: Core
library;

import 'exceptions.dart';

/// Base failure abstraction used by domain and presentation layers.
abstract class Failure {
  /// Creates a failure with a human-readable [message].
  ///
  /// Parameters:
  /// - [message]: Error text safe for logs and UI feedback.
  ///
  /// Return value:
  /// - A configured [Failure] subtype.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const Failure(this.message);

  /// Readable failure detail.
  final String message;

  /// Returns [message] for diagnostics.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Readable failure message.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  @override
  String toString() => message;
}

/// Failure used for API and server-related problems.
class ServerFailure extends Failure {
  /// Creates a server failure.
  ///
  /// Parameters:
  /// - [message]: Optional server failure message.
  ///
  /// Return value:
  /// - A configured [ServerFailure] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ServerFailure([String message = 'Server failure']) : super(message);
}

/// Failure used for local persistence problems.
class CacheFailure extends Failure {
  /// Creates a cache failure.
  ///
  /// Parameters:
  /// - [message]: Optional cache failure message.
  ///
  /// Return value:
  /// - A configured [CacheFailure] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const CacheFailure([String message = 'Local storage failure'])
      : super(message);
}

/// Failure used for validation problems.
class ValidationFailure extends Failure {
  /// Creates a validation failure.
  ///
  /// Parameters:
  /// - [message]: Optional validation failure message.
  ///
  /// Return value:
  /// - A configured [ValidationFailure] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ValidationFailure([String message = 'Validation failure'])
      : super(message);
}

/// Failure used when no specific category matches.
class UnknownFailure extends Failure {
  /// Creates an unknown failure.
  ///
  /// Parameters:
  /// - [message]: Optional unknown failure message.
  ///
  /// Return value:
  /// - A configured [UnknownFailure] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const UnknownFailure([String message = 'Unknown failure']) : super(message);
}

/// Maps an [exception] into the corresponding [Failure] type.
///
/// Parameters:
/// - [exception]: Application exception thrown by lower-level code.
///
/// Return value:
/// - A feature-safe [Failure] object for repository and UI usage.
///
/// Possible errors:
/// - This function does not throw under normal usage.
Failure mapExceptionToFailure(AppException exception) {
  if (exception is ServerException) {
    return ServerFailure(exception.message);
  }

  if (exception is LocalStorageException) {
    return CacheFailure(exception.message);
  }

  if (exception is ValidationException) {
    return ValidationFailure(exception.message);
  }

  return UnknownFailure(exception.message);
}
''';
  }

  /// Builds `lib/core/error/exceptions.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for shared application exceptions.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildExceptionsFile() {
    return '''/// Shared Exceptions
/// Defines simple exception types reused by all data sources.
/// Layer: Core
library;

/// Base application exception with a user-readable [message].
abstract class AppException implements Exception {
  /// Creates an exception with a descriptive [message].
  ///
  /// Parameters:
  /// - [message]: Readable exception detail.
  ///
  /// Return value:
  /// - A configured [AppException] subtype.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const AppException(this.message);

  /// Readable exception detail.
  final String message;

  /// Returns [message] for diagnostics.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Exception message string.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  @override
  String toString() => message;
}

/// Exception representing API/network failures.
class ServerException extends AppException {
  /// Creates a server exception.
  ///
  /// Parameters:
  /// - [message]: Optional exception detail.
  ///
  /// Return value:
  /// - A configured [ServerException] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ServerException([String message = 'Server exception']) : super(message);
}

/// Exception representing invalid local input.
class ValidationException extends AppException {
  /// Creates a validation exception.
  ///
  /// Parameters:
  /// - [message]: Optional exception detail.
  ///
  /// Return value:
  /// - A configured [ValidationException] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ValidationException([String message = 'Validation exception'])
      : super(message);
}

/// Exception representing local storage failures.
class LocalStorageException extends AppException {
  /// Creates a local storage exception.
  ///
  /// Parameters:
  /// - [message]: Optional exception detail.
  ///
  /// Return value:
  /// - A configured [LocalStorageException] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const LocalStorageException([String message = 'Local storage exception'])
      : super(message);
}
''';
  }

  /// Builds `lib/core/result/either.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for a lightweight Either implementation.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildEitherFile() {
    return '''/// Either Result Primitive
/// Provides a simple `Left`/`Right` result model without extra packages.
/// Layer: Core
library;

/// Represents a value that is either left or right.
abstract class Either<L, R> {
  /// Creates an either object.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - A [Left] or [Right] value.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const Either();

  /// Resolves this value into one unified return type.
  ///
  /// Parameters:
  /// - [onLeft]: Callback used when this value is left.
  /// - [onRight]: Callback used when this value is right.
  ///
  /// Return value:
  /// - The callback result for the active side.
  ///
  /// Possible errors:
  /// - Rethrows callback exceptions.
  T fold<T>({
    required T Function(L left) onLeft,
    required T Function(R right) onRight,
  });
}

/// Represents the left side of [Either].
class Left<L, R> extends Either<L, R> {
  /// Creates a left value.
  ///
  /// Parameters:
  /// - [value]: Left payload value.
  ///
  /// Return value:
  /// - A configured [Left] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const Left(this.value);

  /// Left payload.
  final L value;

  /// Executes [onLeft] with [value].
  ///
  /// Parameters:
  /// - [onLeft]: Left callback.
  /// - [onRight]: Right callback.
  ///
  /// Return value:
  /// - Result of [onLeft].
  ///
  /// Possible errors:
  /// - Rethrows callback exceptions.
  @override
  T fold<T>({
    required T Function(L left) onLeft,
    required T Function(R right) onRight,
  }) {
    return onLeft(value);
  }
}

/// Represents the right side of [Either].
class Right<L, R> extends Either<L, R> {
  /// Creates a right value.
  ///
  /// Parameters:
  /// - [value]: Right payload value.
  ///
  /// Return value:
  /// - A configured [Right] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const Right(this.value);

  /// Right payload.
  final R value;

  /// Executes [onRight] with [value].
  ///
  /// Parameters:
  /// - [onLeft]: Left callback.
  /// - [onRight]: Right callback.
  ///
  /// Return value:
  /// - Result of [onRight].
  ///
  /// Possible errors:
  /// - Rethrows callback exceptions.
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

  /// Builds `lib/core/network/api_client.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for a lightweight HTTP client wrapper.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildApiClientFile() {
    return '''/// API Client
/// Provides a lightweight HTTP wrapper used by all feature data sources.
/// Layer: Core
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// Minimal HTTP client wrapper for JSON-based GET requests.
class ApiClient {
  /// Creates an API client for the provided [baseUrl].
  ///
  /// Parameters:
  /// - [baseUrl]: Root API URL, such as `https://api.example.com`.
  /// - [timeout]: Optional request timeout override.
  ///
  /// Return value:
  /// - A configured [ApiClient] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  ApiClient({
    required String baseUrl,
    Duration? timeout,
  })  : _baseUrl = baseUrl,
        _timeout =
            timeout ?? const Duration(seconds: AppConstants.requestTimeoutSec);

  /// Base URL used for all requests.
  final String _baseUrl;

  /// Request timeout applied to all network operations.
  final Duration _timeout;

  /// Shared low-level HTTP client.
  final HttpClient _httpClient = HttpClient();

  /// Sends a GET request and returns decoded JSON.
  ///
  /// Parameters:
  /// - [path]: Endpoint path such as `/v1/auth`.
  /// - [headers]: Optional request headers.
  ///
  /// Return value:
  /// - Decoded JSON map or list.
  ///
  /// Possible errors:
  /// - Throws [ServerException] when network, timeout, or decode fails.
  Future<dynamic> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path);

    try {
      final HttpClientRequest request =
          await _httpClient.getUrl(uri).timeout(_timeout);

      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      headers?.forEach(request.headers.set);

      final HttpClientResponse response = await request.close().timeout(_timeout);
      final String body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          'Request failed with status code \${response.statusCode}.',
        );
      }

      if (body.trim().isEmpty) {
        return <String, dynamic>{};
      }

      return jsonDecode(body);
    } on TimeoutException {
      throw const ServerException('Request timed out.');
    } on SocketException {
      throw const ServerException('Unable to reach the server.');
    } on FormatException {
      throw const ServerException('Invalid JSON response.');
    } on AppException {
      rethrow;
    } catch (error) {
      throw ServerException('Unexpected API error: \${error.toString()}');
    }
  }

  /// Sends a GET request and normalizes response into list-of-map format.
  ///
  /// Parameters:
  /// - [path]: Endpoint path such as `/v1/auth`.
  /// - [headers]: Optional request headers.
  ///
  /// Return value:
  /// - List of map records extracted from JSON payload.
  ///
  /// Possible errors:
  /// - Throws [ServerException] for unsupported response shapes.
  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, String>? headers,
  }) async {
    final dynamic payload = await get(path, headers: headers);

    if (payload is List) {
      return payload
          .whereType<Map>()
          .map<Map<String, dynamic>>(
            (Map item) => Map<String, dynamic>.from(item),
          )
          .toList(growable: false);
    }

    if (payload is Map<String, dynamic>) {
      return <Map<String, dynamic>>[payload];
    }

    throw const ServerException('Unsupported payload format.');
  }

  /// Builds a full request [Uri] from [path].
  ///
  /// Parameters:
  /// - [path]: Relative endpoint path.
  ///
  /// Return value:
  /// - Fully qualified URI for the outgoing request.
  ///
  /// Possible errors:
  /// - Throws [FormatException] when URI construction fails.
  Uri _buildUri(String path) {
    final String normalizedBase =
        _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final String normalizedPath = path.startsWith('/') ? path : '/\$path';
    return Uri.parse('\$normalizedBase\$normalizedPath');
  }
}
''';
  }

  /// Builds `lib/core/utils/logger.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for a lightweight logger.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildLoggerFile() {
    return '''/// Logger Utility
/// Provides lightweight print-based logging for all layers.
/// Layer: Core
library;

/// Simple logger utility intended for starter projects.
class Logger {
  /// Creates a logger instance.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - A configured [Logger] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const Logger();

  /// Logs informational text.
  ///
  /// Parameters:
  /// - [message]: Informational message text.
  ///
  /// Return value:
  /// - None.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  void info(String message) {
    print('[INFO] \${DateTime.now().toIso8601String()} - \$message');
  }

  /// Logs warning text.
  ///
  /// Parameters:
  /// - [message]: Warning message text.
  ///
  /// Return value:
  /// - None.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  void warning(String message) {
    print('[WARN] \${DateTime.now().toIso8601String()} - \$message');
  }

  /// Logs error text.
  ///
  /// Parameters:
  /// - [message]: Error message text.
  ///
  /// Return value:
  /// - None.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  void error(String message) {
    print('[ERROR] \${DateTime.now().toIso8601String()} - \$message');
  }
}
''';
  }

  /// Builds `lib/core/constants/app_constants.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for shared app constants.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildAppConstantsFile() {
    return '''/// Application Constants
/// Stores simple constants shared by networking and presentation.
/// Layer: Core
library;

/// Shared constant values used by multiple modules.
class AppConstants {
  /// Creates a non-instantiable constants namespace.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - This constructor is never used directly.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const AppConstants._();

  /// Default network timeout in seconds.
  static const int requestTimeoutSec = 20;

  /// Shared page padding in logical pixels.
  static const double pagePadding = 16;
}
''';
  }

  /// Builds `lib/shared/widgets/custom_button.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for a reusable button widget.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildCustomButtonFile() {
    return '''/// Custom Button
/// Provides a reusable primary button for app-wide actions.
/// Layer: Shared
library;

import 'package:flutter/material.dart';

/// Standard reusable button with optional loading state.
class CustomButton extends StatelessWidget {
  /// Creates a reusable button.
  ///
  /// Parameters:
  /// - [label]: Text displayed inside the button.
  /// - [onPressed]: Callback executed on tap.
  /// - [isLoading]: Enables loading indicator and disables tap when true.
  /// - [key]: Optional widget key.
  ///
  /// Return value:
  /// - A configured [CustomButton] widget.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const CustomButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  /// Button label text.
  final String label;

  /// Tap handler callback.
  final VoidCallback? onPressed;

  /// Whether loading indicator should be shown.
  final bool isLoading;

  /// Builds the button widget.
  ///
  /// Parameters:
  /// - [context]: Flutter build context.
  ///
  /// Return value:
  /// - Elevated button with optional loading indicator.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
''';
  }

  /// Builds `lib/shared/widgets/custom_loader.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for a reusable loading widget.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildCustomLoaderFile() {
    return '''/// Custom Loader
/// Provides a reusable loading indicator widget.
/// Layer: Shared
library;

import 'package:flutter/material.dart';

/// Standard loader widget used across feature screens.
class CustomLoader extends StatelessWidget {
  /// Creates a loader with optional [size].
  ///
  /// Parameters:
  /// - [size]: Diameter of the loader indicator.
  /// - [key]: Optional widget key.
  ///
  /// Return value:
  /// - A configured [CustomLoader] widget.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const CustomLoader({
    this.size = 28,
    super.key,
  });

  /// Diameter of the loader indicator.
  final double size;

  /// Builds a centered progress indicator.
  ///
  /// Parameters:
  /// - [context]: Flutter build context.
  ///
  /// Return value:
  /// - Centered circular progress indicator widget.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}
''';
  }

  /// Builds `lib/shared/theme/app_theme.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for a basic shared Flutter theme.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildAppThemeFile() {
    return '''/// App Theme
/// Defines a basic reusable light theme configuration.
/// Layer: Shared
library;

import 'package:flutter/material.dart';

/// Shared app theme factory.
class AppTheme {
  /// Creates a non-instantiable theme namespace.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - This constructor is never used directly.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const AppTheme._();

  /// Builds the shared light theme.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - A configured [ThemeData] instance.
  ///
  /// Possible errors:
  /// - This getter does not throw under normal usage.
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}
''';
  }

  /// Builds `lib/shared/helpers/validators.dart`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - File content for reusable validation helpers.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildValidatorsFile() {
    return '''/// Validators
/// Provides reusable input validation helpers for all features.
/// Layer: Shared
library;

/// Shared validation helper methods.
class Validators {
  /// Creates a non-instantiable validators namespace.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - This constructor is never used directly.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const Validators._();

  /// Validates whether [value] looks like an email address.
  ///
  /// Parameters:
  /// - [value]: Raw input value to validate.
  ///
  /// Return value:
  /// - `true` when [value] matches a simple email pattern.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static bool isValidEmail(String value) {
    const String pattern = r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+\$';
    return RegExp(pattern).hasMatch(value.trim());
  }

  /// Validates whether [value] meets password requirements.
  ///
  /// Parameters:
  /// - [value]: Raw password text.
  /// - [minLength]: Minimum required character length.
  ///
  /// Return value:
  /// - `true` when [value] meets minimum length and contains letters and digits.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static bool isValidPassword(
    String value, {
    int minLength = 8,
  }) {
    final String input = value.trim();
    final bool hasLetter = RegExp(r'[A-Za-z]').hasMatch(input);
    final bool hasNumber = RegExp(r'[0-9]').hasMatch(input);
    return input.length >= minLength && hasLetter && hasNumber;
  }

  /// Validates whether [value] is not empty after trimming.
  ///
  /// Parameters:
  /// - [value]: Raw string value.
  ///
  /// Return value:
  /// - `true` when [value] contains at least one non-space character.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }
}
''';
  }
}
