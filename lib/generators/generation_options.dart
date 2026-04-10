/// Generation option models and parsing utilities.
///
/// This file defines strongly typed CLI options used by the feature generator.
library;

/// Supported state-management strategies for generated feature modules.
///
/// This enum is used by the generator layer to select the correct
/// presentation-template builder.
enum StateManagementType {
  /// Generates Riverpod state notifier/provider templates.
  riverpod,

  /// Generates Bloc event/state templates.
  bloc,

  /// Generates GetX controller/reactive templates.
  getx,

  /// Generates Provider + ChangeNotifier templates.
  provider,
}

/// Supported data-source styles for generated data-layer templates.
///
/// This enum is used by the generator layer to select datasource and
/// repository implementation templates.
enum DataSourceType {
  /// Generates REST API-oriented data source templates.
  rest,

  /// Generates Firebase-oriented data source templates.
  firebase,

  /// Generates local storage-oriented data source templates.
  local,
}

/// Extension methods for CLI serialization of [StateManagementType].
///
/// These values are surfaced in command help text and argument parsing logic.
extension StateManagementTypeExtension on StateManagementType {
  /// Converts a state management type to its CLI string representation.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - A lowercase command-line value.
  ///
  /// Possible errors:
  /// - This getter does not throw under normal usage.
  String get cliValue {
    switch (this) {
      case StateManagementType.riverpod:
        return 'riverpod';
      case StateManagementType.bloc:
        return 'bloc';
      case StateManagementType.getx:
        return 'getx';
      case StateManagementType.provider:
        return 'provider';
    }
  }
}

/// Extension methods for CLI serialization of [DataSourceType].
///
/// These values are surfaced in command help text and argument parsing logic.
extension DataSourceTypeExtension on DataSourceType {
  /// Converts a data source type to its CLI string representation.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - A lowercase command-line value.
  ///
  /// Possible errors:
  /// - This getter does not throw under normal usage.
  String get cliValue {
    switch (this) {
      case DataSourceType.rest:
        return 'rest';
      case DataSourceType.firebase:
        return 'firebase';
      case DataSourceType.local:
        return 'local';
    }
  }
}

/// Immutable options object used when generating a feature module.
///
/// This model is passed from CLI parsing to the generator layer so template
/// selection remains strongly typed.
class GenerationOptions {
  /// Creates a new set of feature generation options.
  ///
  /// Parameters:
  /// - [stateManagement]: Selected state management implementation.
  /// - [dataSource]: Selected data source implementation style.
  ///
  /// Return value:
  /// - A configured [GenerationOptions] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const GenerationOptions({
    required this.stateManagement,
    required this.dataSource,
  });

  /// The selected state management implementation.
  final StateManagementType stateManagement;

  /// The selected data source implementation.
  final DataSourceType dataSource;
}

/// Parses a CLI [input] value into a [StateManagementType].
///
/// Parameters:
/// - [input]: Raw CLI string such as `riverpod`.
///
/// Return value:
/// - The parsed [StateManagementType].
///
/// Possible errors:
/// - Throws [FormatException] when [input] is unsupported.
StateManagementType parseStateManagementType(String input) {
  switch (input.toLowerCase()) {
    case 'riverpod':
      return StateManagementType.riverpod;
    case 'bloc':
      return StateManagementType.bloc;
    case 'getx':
      return StateManagementType.getx;
    case 'provider':
      return StateManagementType.provider;
    default:
      throw FormatException(
        'Unsupported state management value: $input. '
        'Allowed values: riverpod, bloc, getx, provider.',
      );
  }
}

/// Parses a CLI [input] value into a [DataSourceType].
///
/// Parameters:
/// - [input]: Raw CLI string such as `rest`.
///
/// Return value:
/// - The parsed [DataSourceType].
///
/// Possible errors:
/// - Throws [FormatException] when [input] is unsupported.
DataSourceType parseDataSourceType(String input) {
  switch (input.toLowerCase()) {
    case 'rest':
      return DataSourceType.rest;
    case 'firebase':
      return DataSourceType.firebase;
    case 'local':
      return DataSourceType.local;
    default:
      throw FormatException(
        'Unsupported data source value: $input. '
        'Allowed values: rest, firebase, local.',
      );
  }
}
