/// Builds shared feature templates used across all state-management styles.
library;

import '../../generators/generation_options.dart';
import '../../generators/naming_convention.dart';

/// Carries data-source class and file metadata for template composition.
class DataSourceTemplateMetadata {
  /// Creates immutable data-source metadata.
  const DataSourceTemplateMetadata({
    required this.className,
    required this.fileName,
  });

  /// Generated data-source class name.
  final String className;

  /// Generated data-source file name.
  final String fileName;
}

/// Builds non-state feature files for clean architecture layers.
class CommonTemplates {
  /// Resolves data-source metadata for the selected source type.
  static DataSourceTemplateMetadata resolveDataSourceMetadata(
    FeatureNaming naming,
    DataSourceType dataSourceType,
  ) {
    switch (dataSourceType) {
      case DataSourceType.rest:
        return DataSourceTemplateMetadata(
          className: '${naming.pascalCase}RestDataSource',
          fileName: '${naming.snakeCase}_rest_data_source.dart',
        );
      case DataSourceType.firebase:
        return DataSourceTemplateMetadata(
          className: '${naming.pascalCase}FirebaseDataSource',
          fileName: '${naming.snakeCase}_firebase_data_source.dart',
        );
      case DataSourceType.local:
        return DataSourceTemplateMetadata(
          className: '${naming.pascalCase}LocalDataSource',
          fileName: '${naming.snakeCase}_local_data_source.dart',
        );
    }
  }

  /// Builds all non-state files for one feature.
  static Map<String, String> buildSharedFiles({
    required FeatureNaming naming,
    required DataSourceType dataSourceType,
    required String stateClassName,
    required String stateFactoryExpression,
    required String stateFileImportPath,
  }) {
    final DataSourceTemplateMetadata dataSourceMetadata =
        resolveDataSourceMetadata(naming, dataSourceType);
    return <String, String>{
      'domain/entities/${naming.snakeCase}_entity.dart':
          buildEntityTemplate(naming),
      'domain/repositories/${naming.snakeCase}_repository.dart':
          buildRepositoryContractTemplate(naming),
      'domain/usecases/get_${naming.snakeCase}_items_use_case.dart':
          buildUseCaseTemplate(naming),
      'data/models/${naming.snakeCase}_model.dart': buildModelTemplate(naming),
      'data/datasources/${dataSourceMetadata.fileName}':
          buildDataSourceTemplate(naming, dataSourceType),
      'data/repositories/${naming.snakeCase}_repository_impl.dart':
          buildRepositoryImplementationTemplate(naming, dataSourceType),
      'presentation/widgets/${naming.snakeCase}_view.dart':
          buildViewTemplate(naming),
      '${naming.snakeCase}_di.dart': buildDependencyInjectionTemplate(
        naming: naming,
        dataSourceType: dataSourceType,
        stateClassName: stateClassName,
        stateFactoryExpression: stateFactoryExpression,
        stateFileImportPath: stateFileImportPath,
      ),
    };
  }

  /// Builds the generated domain entity file.
  static String buildEntityTemplate(FeatureNaming naming) {
    return '''library;

class ${naming.pascalCase}Entity {
  const ${naming.pascalCase}Entity({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}
''';
  }

  /// Builds the generated repository contract file.
  static String buildRepositoryContractTemplate(FeatureNaming naming) {
    return '''library;

import '../../../../core/error/failure.dart';
import '../../../../core/result/either.dart';
import '../entities/${naming.snakeCase}_entity.dart';

abstract class ${naming.pascalCase}Repository {
  Future<Either<Failure, List<${naming.pascalCase}Entity>>> get${naming.pascalCase}Items();
}
''';
  }

  /// Builds the generated use-case file.
  static String buildUseCaseTemplate(FeatureNaming naming) {
    return '''library;

import '../../../../core/error/failure.dart';
import '../../../../core/result/either.dart';
import '../entities/${naming.snakeCase}_entity.dart';
import '../repositories/${naming.snakeCase}_repository.dart';

class Get${naming.pascalCase}ItemsUseCase {
  const Get${naming.pascalCase}ItemsUseCase({
    required ${naming.pascalCase}Repository repository,
  }) : _repository = repository;

  final ${naming.pascalCase}Repository _repository;

  Future<Either<Failure, List<${naming.pascalCase}Entity>>> call() {
    // Executes use case
    return _repository.get${naming.pascalCase}Items();
  }
}
''';
  }

  /// Builds the generated model file.
  static String buildModelTemplate(FeatureNaming naming) {
    return '''library;

import '../../domain/entities/${naming.snakeCase}_entity.dart';

class ${naming.pascalCase}Model extends ${naming.pascalCase}Entity {
  const ${naming.pascalCase}Model({
    required super.id,
    required super.title,
  });

  factory ${naming.pascalCase}Model.fromMap(Map<String, dynamic> map) {
    // Parses model from map
    return ${naming.pascalCase}Model(
      id: map['id'].toString(),
      title: map['title'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    // Converts model to map
    return <String, dynamic>{'id': id, 'title': title};
  }
}
''';
  }

  /// Builds the generated data-source file by source type.
  static String buildDataSourceTemplate(
    FeatureNaming naming,
    DataSourceType dataSourceType,
  ) {
    switch (dataSourceType) {
      case DataSourceType.rest:
        return _buildRestDataSourceTemplate(naming);
      case DataSourceType.firebase:
        return _buildFirebaseDataSourceTemplate(naming);
      case DataSourceType.local:
        return _buildLocalDataSourceTemplate(naming);
    }
  }

  /// Builds the generated repository implementation file.
  static String buildRepositoryImplementationTemplate(
    FeatureNaming naming,
    DataSourceType dataSourceType,
  ) {
    final DataSourceTemplateMetadata metadata =
        resolveDataSourceMetadata(naming, dataSourceType);
    return '''library;

import 'package:dio/dio.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result/either.dart';
import '../../domain/entities/${naming.snakeCase}_entity.dart';
import '../../domain/repositories/${naming.snakeCase}_repository.dart';
import '../datasources/${metadata.fileName}';
import '../models/${naming.snakeCase}_model.dart';

class ${naming.pascalCase}RepositoryImpl implements ${naming.pascalCase}Repository {
  const ${naming.pascalCase}RepositoryImpl({
    required ${metadata.className} dataSource,
  }) : _dataSource = dataSource;

  final ${metadata.className} _dataSource;

  @override
  Future<Either<Failure, List<${naming.pascalCase}Entity>>> get${naming.pascalCase}Items() async {
    // Maps data source output to domain entities
    try {
      final List<Map<String, dynamic>> rawItems = await _dataSource.fetch${naming.pascalCase}Items();
      final List<${naming.pascalCase}Entity> entities = rawItems
          .map<${naming.pascalCase}Entity>(${naming.pascalCase}Model.fromMap)
          .toList(growable: false);
      return Right<Failure, List<${naming.pascalCase}Entity>>(entities);
    } on DioException catch (exception) {
      return Left<Failure, List<${naming.pascalCase}Entity>>(
        mapDioExceptionToFailure(exception),
      );
    } catch (error) {
      return Left<Failure, List<${naming.pascalCase}Entity>>(
        UnknownFailure('Unexpected repository error: \${error.toString()}'),
      );
    }
  }
}
''';
  }

  /// Builds the generated presentation view file.
  static String buildViewTemplate(FeatureNaming naming) {
    return '''library;

import 'package:flutter/material.dart';

import '../../domain/entities/${naming.snakeCase}_entity.dart';

class ${naming.pascalCase}View extends StatelessWidget {
  const ${naming.pascalCase}View({
    required this.isLoading,
    required this.errorMessage,
    required this.items,
    required this.onRetry,
    super.key,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<${naming.pascalCase}Entity> items;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Builds current view state
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null && errorMessage!.trim().isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (items.isEmpty) {
      return const Center(child: Text('No items found.'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        // Builds one list item
        final ${naming.pascalCase}Entity item = items[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text('ID: \${item.id}'),
        );
      },
    );
  }
}
''';
  }

  /// Builds the generated feature dependency registration file.
  static String buildDependencyInjectionTemplate({
    required FeatureNaming naming,
    required DataSourceType dataSourceType,
    required String stateClassName,
    required String stateFactoryExpression,
    required String stateFileImportPath,
  }) {
    final DataSourceTemplateMetadata metadata =
        resolveDataSourceMetadata(naming, dataSourceType);
    return '''library;

import 'package:get_it/get_it.dart';

import '../../config/app_config.dart';
${_buildDependencyInjectionCoreImports(dataSourceType)}
import 'data/datasources/${metadata.fileName}';
import 'data/repositories/${naming.snakeCase}_repository_impl.dart';
import 'domain/repositories/${naming.snakeCase}_repository.dart';
import 'domain/usecases/get_${naming.snakeCase}_items_use_case.dart';
import '$stateFileImportPath';

final GetIt sl = GetIt.instance;

Future<void> init${naming.pascalCase}Dependencies() async {
  // Registers feature dependency graph
${_buildApiClientRegistrationSnippet(dataSourceType)}
${_buildDataSourceRegistrationSnippet(metadata, dataSourceType)}
  if (!sl.isRegistered<${naming.pascalCase}Repository>()) {
    sl.registerLazySingleton<${naming.pascalCase}Repository>(
      () => ${naming.pascalCase}RepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<Get${naming.pascalCase}ItemsUseCase>()) {
    sl.registerLazySingleton<Get${naming.pascalCase}ItemsUseCase>(
      () => Get${naming.pascalCase}ItemsUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<$stateClassName>()) {
    sl.registerFactory<$stateClassName>(() => $stateFactoryExpression);
  }
}
''';
  }

  /// Builds data-source registration snippet for generated DI.
  static String _buildDataSourceRegistrationSnippet(
    DataSourceTemplateMetadata metadata,
    DataSourceType dataSourceType,
  ) {
    switch (dataSourceType) {
      case DataSourceType.rest:
        return '''  if (!sl.isRegistered<${metadata.className}>()) {
    sl.registerLazySingleton<${metadata.className}>(
      () => ${metadata.className}(apiClient: sl()),
    );
  }
''';
      case DataSourceType.firebase:
      case DataSourceType.local:
        return '''  if (!sl.isRegistered<${metadata.className}>()) {
    sl.registerLazySingleton<${metadata.className}>(
      () => ${metadata.className}(),
    );
  }
''';
    }
  }

  /// Builds core imports used by generated DI.
  static String _buildDependencyInjectionCoreImports(
    DataSourceType dataSourceType,
  ) {
    switch (dataSourceType) {
      case DataSourceType.rest:
        return '''import '../../core/network/api_client.dart';
''';
      case DataSourceType.firebase:
      case DataSourceType.local:
        return '';
    }
  }

  /// Builds API client registration snippet for generated DI.
  static String _buildApiClientRegistrationSnippet(
    DataSourceType dataSourceType,
  ) {
    switch (dataSourceType) {
      case DataSourceType.rest:
        return '''  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient(
        baseUrl: AppConfig.baseUrl(),
        tokenProvider: () async => null,
      ),
    );
  }
''';
      case DataSourceType.firebase:
      case DataSourceType.local:
        return '';
    }
  }

  /// Builds generated REST data source file.
  static String _buildRestDataSourceTemplate(FeatureNaming naming) {
    return '''library;

import 'package:dio/dio.dart';

import '../../../../config/app_config.dart';
import '../../../../core/network/api_client.dart';

class ${naming.pascalCase}RestDataSource {
  const ${naming.pascalCase}RestDataSource({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> fetch${naming.pascalCase}Items() async {
    // Fetches remote items
    final String endpointPath = '\${AppConfig.apiVersion}/${naming.snakeCase}';
    final Response<dynamic> response = await _apiClient.dio.get(endpointPath);
    final dynamic data = response.data;
    if (data is List) {
      return data
          .whereType<Map>()
          .map<Map<String, dynamic>>(
            (Map item) => Map<String, dynamic>.from(item),
          )
          .toList(growable: false);
    }
    if (data is Map<String, dynamic>) {
      return <Map<String, dynamic>>[data];
    }
    return <Map<String, dynamic>>[];
  }
}
''';
  }

  /// Builds generated Firebase data source file.
  static String _buildFirebaseDataSourceTemplate(FeatureNaming naming) {
    return '''library;

class ${naming.pascalCase}FirebaseDataSource {
  const ${naming.pascalCase}FirebaseDataSource();

  Future<List<Map<String, dynamic>>> fetch${naming.pascalCase}Items() async {
    // Throws when firebase source is unconfigured
    throw UnsupportedError('Firebase source is not configured.');
  }
}
''';
  }

  /// Builds generated local data source file.
  static String _buildLocalDataSourceTemplate(FeatureNaming naming) {
    return '''library;

class ${naming.pascalCase}LocalDataSource {
  const ${naming.pascalCase}LocalDataSource();

  Future<List<Map<String, dynamic>>> fetch${naming.pascalCase}Items() async {
    // Throws when local source is unconfigured
    throw UnsupportedError('Local source is not configured.');
  }
}
''';
  }
}
