/// Shared output model for state-management template builders.
///
/// This file defines the structure returned by state template builders to the
/// feature generator.
library;

/// Describes generated state-management files and dependency metadata.
///
/// Each state template builder returns this payload so the generator can merge
/// files and wire the correct class into feature DI.
class StateTemplateOutput {
  /// Creates a [StateTemplateOutput] payload.
  ///
  /// Parameters:
  /// - [filesByRelativePath]: Generated files relative to the feature root.
  /// - [stateClassName]: Primary state class registered in DI.
  /// - [stateFileImportPath]: Import path to the state class file from DI.
  /// - [stateFactoryExpression]: Expression used to instantiate the state class.
  ///
  /// Return value:
  /// - A fully configured [StateTemplateOutput] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const StateTemplateOutput({
    required this.filesByRelativePath,
    required this.stateClassName,
    required this.stateFileImportPath,
    required this.stateFactoryExpression,
  });

  /// Generated files relative to a feature root directory.
  final Map<String, String> filesByRelativePath;

  /// Primary state class used for DI registration.
  final String stateClassName;

  /// Relative import path to the state file from `<feature>_di.dart`.
  final String stateFileImportPath;

  /// Factory expression used by DI to instantiate [stateClassName].
  final String stateFactoryExpression;
}
