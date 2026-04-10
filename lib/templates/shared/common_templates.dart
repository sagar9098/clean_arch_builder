/// Shared template builders for non-state-specific feature files.
///
/// This file contains reusable templates for domain, data, presentation view,
/// and dependency injection files that are common across state solutions.
library;

import '../../generators/generation_options.dart';
import '../../generators/naming_convention.dart';

/// Metadata describing generated data source files and class names.
///
/// This model allows repository and DI templates to stay generic while still
/// selecting the correct concrete data source implementation.
class DataSourceTemplateMetadata {
  /// Creates metadata for a generated data source template.
  ///
  /// Parameters:
  /// - [className]: Dart class name for the data source.
  /// - [fileName]: Target file name for the data source.
  /// - [displayName]: Human-readable source type label.
  ///
  /// Return value:
  /// - A configured [DataSourceTemplateMetadata] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const DataSourceTemplateMetadata({
    required this.className,
    required this.fileName,
    required this.displayName,
  });

  /// Generated class name of the data source.
  final String className;

  /// Generated file name of the data source.
  final String fileName;

  /// Human-readable source type name.
  final String displayName;
}

/// Builds shared templates used by all generated feature variants.
///
/// This builder creates non-state-specific files for domain, data, shared
/// presentation widgets, and dependency injection.
class CommonTemplates {
  /// Resolves data source metadata for [dataSourceType] and [naming].
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  /// - [dataSourceType]: Selected data source strategy.
  ///
  /// Return value:
  /// - [DataSourceTemplateMetadata] for class/file generation.
  ///
  /// Possible errors:
  /// - Throws [UnsupportedError] for unknown enum values.
  static DataSourceTemplateMetadata resolveDataSourceMetadata(
    FeatureNaming naming,
    DataSourceType dataSourceType,
  ) {
    switch (dataSourceType) {
      case DataSourceType.rest:
        return DataSourceTemplateMetadata(
          className: '${naming.pascalCase}RestDataSource',
          fileName: '${naming.snakeCase}_rest_data_source.dart',
          displayName: 'REST',
        );
      case DataSourceType.firebase:
        return DataSourceTemplateMetadata(
          className: '${naming.pascalCase}FirebaseDataSource',
          fileName: '${naming.snakeCase}_firebase_data_source.dart',
          displayName: 'Firebase',
        );
      case DataSourceType.local:
        return DataSourceTemplateMetadata(
          className: '${naming.pascalCase}LocalDataSource',
          fileName: '${naming.snakeCase}_local_data_source.dart',
          displayName: 'Local',
        );
    }
  }

  /// Builds all non-state-specific files for a feature.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  /// - [dataSourceType]: Selected data source strategy.
  /// - [stateClassName]: Main state class used by DI.
  /// - [stateFactoryExpression]: DI expression that creates state instances.
  /// - [stateFileImportPath]: Relative import path for the state file in DI.
  ///
  /// Return value:
  /// - Map of relative file paths to generated Dart source.
  ///
  /// Possible errors:
  /// - Throws [UnsupportedError] if [dataSourceType] is not recognized.
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

  /// Builds the domain entity template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for the feature entity class.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String buildEntityTemplate(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} Entity
/// Defines the core business object for the ${naming.titleCase} feature.
/// Layer: Domain
library;

/// Immutable entity used across domain and presentation layers.
class ${naming.pascalCase}Entity {
  /// Creates an immutable ${naming.pascalCase} business entity.
  ///
  /// Parameters:
  /// - [id]: Unique identifier for the entity.
  /// - [title]: Display title for the entity.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}Entity] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ${naming.pascalCase}Entity({
    required this.id,
    required this.title,
  });

  /// Unique identifier.
  final String id;

  /// Human-readable title.
  final String title;
}
''';
  }

  /// Builds the domain repository contract template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for the abstract repository contract.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String buildRepositoryContractTemplate(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} Repository Contract
/// Defines the domain abstraction implemented by data layer repositories.
/// Layer: Domain
library;

import '../../../../core/error/failure.dart';
import '../../../../core/result/either.dart';
import '../entities/${naming.snakeCase}_entity.dart';

/// Domain contract for ${naming.titleCase} operations.
abstract class ${naming.pascalCase}Repository {
  /// Retrieves ${naming.titleCase} entities from the configured data source.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - [Right] with a list of entities on success.
  /// - [Left] with a [Failure] on error.
  ///
  /// Possible errors:
  /// - Implementations should return failures instead of throwing.
  Future<Either<Failure, List<${naming.pascalCase}Entity>>> get${naming.pascalCase}Items();
}
''';
  }

  /// Builds the domain use case template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for the feature retrieval use case.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String buildUseCaseTemplate(FeatureNaming naming) {
    return '''/// Get ${naming.pascalCase} Items Use Case
/// Orchestrates retrieval of ${naming.titleCase} entities from the repository.
/// Layer: Domain
library;

import '../../../../core/error/failure.dart';
import '../../../../core/result/either.dart';
import '../entities/${naming.snakeCase}_entity.dart';
import '../repositories/${naming.snakeCase}_repository.dart';

/// Use case that loads ${naming.titleCase} records for presentation.
class Get${naming.pascalCase}ItemsUseCase {
  /// Creates the use case with an injected [repository].
  ///
  /// Parameters:
  /// - [repository]: Domain repository dependency.
  ///
  /// Return value:
  /// - A configured [Get${naming.pascalCase}ItemsUseCase] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const Get${naming.pascalCase}ItemsUseCase({
    required ${naming.pascalCase}Repository repository,
  }) : _repository = repository;

  /// Underlying repository used to fetch entities.
  final ${naming.pascalCase}Repository _repository;

  /// Executes entity retrieval.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - [Right] with data when successful.
  /// - [Left] with [Failure] when retrieval fails.
  ///
  /// Possible errors:
  /// - Implementations should return failures rather than throw.
  Future<Either<Failure, List<${naming.pascalCase}Entity>>> call() {
    return _repository.get${naming.pascalCase}Items();
  }
}
''';
  }

  /// Builds the data model template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for serializable feature model.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String buildModelTemplate(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} Model
/// Maps raw data payloads into domain entities for ${naming.titleCase}.
/// Layer: Data
library;

import '../../domain/entities/${naming.snakeCase}_entity.dart';

/// Concrete data model that extends the domain entity.
class ${naming.pascalCase}Model extends ${naming.pascalCase}Entity {
  /// Creates a data model using entity-compatible fields.
  ///
  /// Parameters:
  /// - [id]: Unique identifier.
  /// - [title]: Display title.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}Model] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ${naming.pascalCase}Model({
    required super.id,
    required super.title,
  });

  /// Builds a model from a map payload.
  ///
  /// Parameters:
  /// - [map]: Raw key-value data from a data source.
  ///
  /// Return value:
  /// - A parsed [${naming.pascalCase}Model] instance.
  ///
  /// Possible errors:
  /// - Throws [FormatException] when required keys are missing.
  factory ${naming.pascalCase}Model.fromMap(Map<String, dynamic> map) {
    final Object? idValue = map['id'];
    final Object? titleValue = map['title'];

    if (idValue == null || titleValue == null) {
      throw const FormatException(
        'Invalid payload. Required keys: id, title.',
      );
    }

    return ${naming.pascalCase}Model(
      id: idValue.toString(),
      title: titleValue.toString(),
    );
  }

  /// Converts this model to a serializable map.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Map representation containing `id` and `title` keys.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
    };
  }
}
''';
  }

  /// Builds the selected data source template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  /// - [dataSourceType]: Selected data source strategy.
  ///
  /// Return value:
  /// - File content for a concrete data source class.
  ///
  /// Possible errors:
  /// - Throws [UnsupportedError] for unknown enum values.
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

  /// Builds the concrete repository implementation template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  /// - [dataSourceType]: Selected data source strategy.
  ///
  /// Return value:
  /// - File content for data-layer repository implementation.
  ///
  /// Possible errors:
  /// - Throws [UnsupportedError] for unknown enum values.
  static String buildRepositoryImplementationTemplate(
    FeatureNaming naming,
    DataSourceType dataSourceType,
  ) {
    final DataSourceTemplateMetadata metadata =
        resolveDataSourceMetadata(naming, dataSourceType);

    return '''/// ${naming.pascalCase} Repository Implementation
/// Handles ${naming.titleCase} data retrieval and maps payloads to entities.
/// Layer: Data
library;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/result/either.dart';
import '../../domain/entities/${naming.snakeCase}_entity.dart';
import '../../domain/repositories/${naming.snakeCase}_repository.dart';
import '../datasources/${metadata.fileName}';
import '../models/${naming.snakeCase}_model.dart';

/// Concrete data-layer implementation of [${naming.pascalCase}Repository].
class ${naming.pascalCase}RepositoryImpl implements ${naming.pascalCase}Repository {
  /// Creates repository implementation with injected [dataSource].
  ///
  /// Parameters:
  /// - [dataSource]: Concrete data source dependency.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}RepositoryImpl] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ${naming.pascalCase}RepositoryImpl({
    required ${metadata.className} dataSource,
  }) : _dataSource = dataSource;

  /// Underlying data source abstraction for ${metadata.displayName} access.
  final ${metadata.className} _dataSource;

  /// Fetches and maps entities from the configured data source.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - [Right] with mapped entities when successful.
  /// - [Left] with [Failure] when any conversion or source operation fails.
  ///
  /// Possible errors:
  /// - Returns mapped [Failure] instances instead of propagating exceptions.
  @override
  Future<Either<Failure, List<${naming.pascalCase}Entity>>> get${naming.pascalCase}Items() async {
    try {
      final List<Map<String, dynamic>> rawItems = await _dataSource.fetch${naming.pascalCase}Items();
      final List<${naming.pascalCase}Entity> entities = rawItems
          .map<${naming.pascalCase}Entity>(${naming.pascalCase}Model.fromMap)
          .toList(growable: false);

      return Right<Failure, List<${naming.pascalCase}Entity>>(entities);
    } on AppException catch (exception) {
      return Left<Failure, List<${naming.pascalCase}Entity>>(
        mapExceptionToFailure(exception),
      );
    } catch (error) {
      return Left<Failure, List<${naming.pascalCase}Entity>>(
        UnknownFailure(
          'Unexpected repository error: '
          '\${error.toString()}',
        ),
      );
    }
  }
}
''';
  }

  /// Builds the shared presentation view widget.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for a reusable UI rendering widget.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String buildViewTemplate(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} View Widget
/// Renders loading, error, and data states for ${naming.titleCase} items.
/// Layer: Presentation
library;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/helpers/validators.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_loader.dart';
import '../../domain/entities/${naming.snakeCase}_entity.dart';

/// Stateless view used by page/state layers to display UI states.
class ${naming.pascalCase}View extends StatelessWidget {
  /// Creates a view with render-state parameters.
  ///
  /// Parameters:
  /// - [isLoading]: Indicates active loading state.
  /// - [errorMessage]: Optional error text.
  /// - [items]: Loaded domain entities.
  /// - [onRetry]: Callback used for retry action.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}View] widget.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ${naming.pascalCase}View({
    required this.isLoading,
    required this.errorMessage,
    required this.items,
    required this.onRetry,
    super.key,
  });

  /// Whether the page is currently loading.
  final bool isLoading;

  /// Optional error text to display to users.
  final String? errorMessage;

  /// Collection of items displayed in the success state.
  final List<${naming.pascalCase}Entity> items;

  /// Retry callback for error state interactions.
  final VoidCallback onRetry;

  /// Builds widget tree based on current state fields.
  ///
  /// Parameters:
  /// - [context]: Flutter build context.
  ///
  /// Return value:
  /// - A widget that represents loading, error, or data state.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null && Validators.isNotEmpty(errorMessage!)) {
      return _buildErrorState();
    }

    return _buildDataState();
  }

  /// Builds a loading indicator widget.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Centered reusable loading widget.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  Widget _buildLoadingState() {
    return const CustomLoader();
  }

  /// Builds an error state widget with retry action.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Error text and reusable retry button.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Retry',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a data list widget.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - ListView that renders item titles.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  Widget _buildDataState() {
    if (items.isEmpty) {
      return const Center(
        child: Text('No items found.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final ${naming.pascalCase}Entity item = items[index];
        final String displayTitle = Validators.isNotEmpty(item.title)
            ? item.title
            : 'Untitled';

        return ListTile(
          leading: const Icon(Icons.folder_open),
          title: Text(displayTitle),
          subtitle: Text('ID: \${item.id}'),
        );
      },
    );
  }
}
''';
  }

  /// Builds feature-level dependency injection setup template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  /// - [dataSourceType]: Selected data source strategy.
  /// - [stateClassName]: Main state class used by DI.
  /// - [stateFactoryExpression]: Factory expression for state creation.
  /// - [stateFileImportPath]: Relative path to state file.
  ///
  /// Return value:
  /// - File content for `<feature>_di.dart`.
  ///
  /// Possible errors:
  /// - Throws [UnsupportedError] when enum values are unsupported.
  static String buildDependencyInjectionTemplate({
    required FeatureNaming naming,
    required DataSourceType dataSourceType,
    required String stateClassName,
    required String stateFactoryExpression,
    required String stateFileImportPath,
  }) {
    final DataSourceTemplateMetadata metadata =
        resolveDataSourceMetadata(naming, dataSourceType);

    return '''/// ${naming.pascalCase} Dependency Injection
/// Registers data, domain, and presentation dependencies for ${naming.titleCase}.
/// Layer: Feature Composition
library;

import 'package:get_it/get_it.dart';

import '../../core/utils/logger.dart';
${_buildDependencyInjectionCoreImports(dataSourceType)}
import 'data/datasources/${metadata.fileName}';
import 'data/repositories/${naming.snakeCase}_repository_impl.dart';
import 'domain/repositories/${naming.snakeCase}_repository.dart';
import 'domain/usecases/get_${naming.snakeCase}_items_use_case.dart';
import '$stateFileImportPath';

/// Service locator used by this feature's dependency graph.
final GetIt sl = GetIt.instance;

/// Registers all dependencies required by the ${naming.titleCase} feature.
///
/// Parameters:
/// - None.
///
/// Return value:
/// - Completes when all factories and singletons are registered.
///
/// Possible errors:
/// - Throws [StateError] when registration order is invalid.
Future<void> init${naming.pascalCase}Dependencies() async {
  if (!sl.isRegistered<Logger>()) {
    sl.registerLazySingleton<Logger>(() => const Logger());
  }
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

  /// Builds data-source registration snippet for DI templates.
  ///
  /// Parameters:
  /// - [metadata]: Metadata for the selected data source.
  /// - [dataSourceType]: Selected data source strategy.
  ///
  /// Return value:
  /// - Source code snippet for data source registration.
  ///
  /// Possible errors:
  /// - Throws [UnsupportedError] for unknown enum values.
  static String _buildDataSourceRegistrationSnippet(
    DataSourceTemplateMetadata metadata,
    DataSourceType dataSourceType,
  ) {
    switch (dataSourceType) {
      case DataSourceType.rest:
        return '''  if (!sl.isRegistered<${metadata.className}>()) {
    sl.registerLazySingleton<${metadata.className}>(
      () => ${metadata.className}(apiClient: sl(), logger: sl()),
    );
  }
''';
      case DataSourceType.firebase:
      case DataSourceType.local:
        return '''  if (!sl.isRegistered<${metadata.className}>()) {
    sl.registerLazySingleton<${metadata.className}>(
      () => ${metadata.className}(logger: sl()),
    );
  }
''';
    }
  }

  /// Builds core-import snippets for dependency injection templates.
  ///
  /// Parameters:
  /// - [dataSourceType]: Selected data source strategy.
  ///
  /// Return value:
  /// - Import snippet required by the selected data source type.
  ///
  /// Possible errors:
  /// - Throws [UnsupportedError] for unknown enum values.
  static String _buildDependencyInjectionCoreImports(
    DataSourceType dataSourceType,
  ) {
    switch (dataSourceType) {
      case DataSourceType.rest:
        return '''import '../../config/app_config.dart';
import '../../core/network/api_client.dart';
''';
      case DataSourceType.firebase:
      case DataSourceType.local:
        return '';
    }
  }

  /// Builds optional API client registration snippet for DI templates.
  ///
  /// Parameters:
  /// - [dataSourceType]: Selected data source strategy.
  ///
  /// Return value:
  /// - Source code snippet for API client registration when needed.
  ///
  /// Possible errors:
  /// - Throws [UnsupportedError] for unknown enum values.
  static String _buildApiClientRegistrationSnippet(
    DataSourceType dataSourceType,
  ) {
    switch (dataSourceType) {
      case DataSourceType.rest:
        return '''  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient(baseUrl: AppConfig.baseUrl),
    );
  }
''';
      case DataSourceType.firebase:
      case DataSourceType.local:
        return '';
    }
  }

  /// Builds REST data source template with API client usage.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for REST data source.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildRestDataSourceTemplate(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} REST Data Source
/// Calls remote APIs for ${naming.titleCase} and returns raw payload maps.
/// Layer: Data
library;

import '../../../../config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

/// REST-based source responsible for remote ${naming.titleCase} retrieval.
class ${naming.pascalCase}RestDataSource {
  /// Creates a REST data source.
  ///
  /// Parameters:
  /// - [apiClient]: Shared API client for HTTP calls.
  /// - [logger]: Shared logger for diagnostics.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}RestDataSource] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ${naming.pascalCase}RestDataSource({
    required ApiClient apiClient,
    required Logger logger,
  })  : _apiClient = apiClient,
        _logger = logger;

  /// Shared API client.
  final ApiClient _apiClient;

  /// Shared logger.
  final Logger _logger;

  /// Fetches ${naming.titleCase} records from a remote API endpoint.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - List of raw map payloads.
  ///
  /// Possible errors:
  /// - Throws [AppException] for API, parsing, or network failures.
  Future<List<Map<String, dynamic>>> fetch${naming.pascalCase}Items() async {
    final String endpointPath = '\${AppConfig.apiVersion}/${naming.snakeCase}';

    try {
      _logger.info('Fetching ${naming.titleCase} from \$endpointPath');
      return await _apiClient.getList(endpointPath);
    } on AppException {
      rethrow;
    } catch (error) {
      throw ServerException(
        'Failed to fetch ${naming.titleCase} from REST source: '
        '\${error.toString()}',
      );
    }
  }
}
''';
  }

  /// Builds Firebase data source template with mock structure.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for Firebase data source.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildFirebaseDataSourceTemplate(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} Firebase Data Source
/// Provides a Firebase-oriented placeholder for ${naming.titleCase} retrieval.
/// Layer: Data
library;

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Firebase-based source for ${naming.titleCase} items.
class ${naming.pascalCase}FirebaseDataSource {
  /// Creates a Firebase data source.
  ///
  /// Parameters:
  /// - [logger]: Shared logger for diagnostics.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}FirebaseDataSource] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ${naming.pascalCase}FirebaseDataSource({
    required Logger logger,
  }) : _logger = logger;

  /// Shared logger.
  final Logger _logger;

  /// Fetches ${naming.titleCase} items from Firebase collections.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - List of raw map payloads.
  ///
  /// Possible errors:
  /// - Throws [AppException] when placeholder retrieval fails.
  Future<List<Map<String, dynamic>>> fetch${naming.pascalCase}Items() async {
    try {
      _logger.info('Returning mock Firebase data for ${naming.titleCase}.');
      return <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'firebase-1',
          'title': '${naming.titleCase} Firebase Item',
        },
      ];
    } catch (error) {
      throw ServerException(
        'Failed to fetch ${naming.titleCase} from Firebase source: '
        '\${error.toString()}',
      );
    }
  }
}
''';
  }

  /// Builds local data source template with placeholder structure.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for local data source.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildLocalDataSourceTemplate(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} Local Data Source
/// Provides a local-storage placeholder for ${naming.titleCase} retrieval.
/// Layer: Data
library;

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';

/// Local-storage source for ${naming.titleCase} items.
class ${naming.pascalCase}LocalDataSource {
  /// Creates a local data source.
  ///
  /// Parameters:
  /// - [logger]: Shared logger for diagnostics.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}LocalDataSource] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ${naming.pascalCase}LocalDataSource({
    required Logger logger,
  }) : _logger = logger;

  /// Shared logger.
  final Logger _logger;

  /// Fetches ${naming.titleCase} items from local persistence.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - List of raw map payloads.
  ///
  /// Possible errors:
  /// - Throws [AppException] when local retrieval fails.
  Future<List<Map<String, dynamic>>> fetch${naming.pascalCase}Items() async {
    try {
      _logger.info('Returning mock local data for ${naming.titleCase}.');
      return <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'local-1',
          'title': '${naming.titleCase} Offline Item',
        },
      ];
    } catch (error) {
      throw LocalStorageException(
        'Failed to load ${naming.titleCase} from local source: '
        '\${error.toString()}',
      );
    }
  }
}
''';
  }
}
