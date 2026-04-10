/// Feature generation orchestrator.
///
/// This file coordinates template selection, naming, and safe file writes to
/// generate complete Clean Architecture feature modules.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../templates/bloc/bloc_templates.dart';
import '../templates/getx/getx_templates.dart';
import '../templates/provider/provider_templates.dart';
import '../templates/riverpod/riverpod_templates.dart';
import '../templates/shared/common_templates.dart';
import '../templates/shared/state_template_output.dart';
import 'generation_options.dart';
import 'naming_convention.dart';
import 'project_scaffold_generator.dart';
import 'safe_file_writer.dart';

/// Result details for a completed feature generation operation.
///
/// This payload is returned to the CLI layer for success and summary logging.
class FeatureGenerationResult {
  /// Creates a [FeatureGenerationResult] summary.
  ///
  /// Parameters:
  /// - [featureRootRelativePath]: Feature root path relative to workspace.
  /// - [createdCount]: Number of files created.
  /// - [skippedCount]: Number of files skipped.
  /// - [projectCreatedCount]: Number of created shared scaffold files.
  /// - [projectSkippedCount]: Number of skipped shared scaffold files.
  ///
  /// Return value:
  /// - A configured [FeatureGenerationResult] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const FeatureGenerationResult({
    required this.featureRootRelativePath,
    required this.createdCount,
    required this.skippedCount,
    required this.projectCreatedCount,
    required this.projectSkippedCount,
  });

  /// Relative path to generated feature root directory.
  final String featureRootRelativePath;

  /// Number of files newly created.
  final int createdCount;

  /// Number of files skipped because they already existed.
  final int skippedCount;

  /// Number of shared project scaffold files created during this run.
  final int projectCreatedCount;

  /// Number of shared project scaffold files skipped during this run.
  final int projectSkippedCount;
}

/// Generates complete feature modules following Clean Architecture.
///
/// This class orchestrates naming, template selection, file-path assembly, and
/// safe writes into the target workspace.
class FeatureGenerator {
  /// Creates a [FeatureGenerator] bound to [workingDirectory].
  ///
  /// Parameters:
  /// - [workingDirectory]: Workspace root where files are generated.
  /// - [infoLogger]: Optional informational logger callback.
  /// - [warningLogger]: Optional warning logger callback.
  ///
  /// Return value:
  /// - A configured [FeatureGenerator] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  FeatureGenerator({
    Directory? workingDirectory,
    this.infoLogger,
    this.warningLogger,
  }) : _workingDirectory = workingDirectory ?? Directory.current;

  /// Workspace root where generation occurs.
  final Directory _workingDirectory;

  /// Optional callback for informational messages.
  final void Function(String message)? infoLogger;

  /// Optional callback for warning messages.
  final void Function(String message)? warningLogger;

  /// Generates a complete feature module from [featureName] and [options].
  ///
  /// Parameters:
  /// - [featureName]: Raw feature identifier from CLI input.
  /// - [options]: Selected state/data generation options.
  ///
  /// Return value:
  /// - [FeatureGenerationResult] summary with created and skipped counts.
  ///
  /// Possible errors:
  /// - Throws [FormatException] for invalid feature names.
  /// - Throws [FileSystemException] when file creation fails.
  Future<FeatureGenerationResult> createFeature(
    String featureName,
    GenerationOptions options,
  ) async {
    final ProjectScaffoldGenerator projectScaffoldGenerator =
        ProjectScaffoldGenerator(
      workingDirectory: _workingDirectory,
      infoLogger: infoLogger,
      warningLogger: warningLogger,
    );
    final ProjectScaffoldResult projectScaffoldResult =
        await projectScaffoldGenerator.initializeProject();

    final FeatureNaming naming = FeatureNaming.fromRaw(featureName);
    final StateTemplateOutput stateOutput = _resolveStateTemplateOutput(
      naming,
      options.stateManagement,
    );

    final Map<String, String> featureRelativeFiles =
        CommonTemplates.buildSharedFiles(
      naming: naming,
      dataSourceType: options.dataSource,
      stateClassName: stateOutput.stateClassName,
      stateFactoryExpression: stateOutput.stateFactoryExpression,
      stateFileImportPath: stateOutput.stateFileImportPath,
    )..addAll(stateOutput.filesByRelativePath);

    final String featureRootRelativePath = p.join(
      'lib',
      'features',
      naming.snakeCase,
    );

    final Map<String, String> projectRelativeFiles = featureRelativeFiles.map(
      (String relativePath, String content) => MapEntry<String, String>(
        p.join(featureRootRelativePath, relativePath),
        content,
      ),
    );

    final SafeFileWriter fileWriter = SafeFileWriter(
      rootDirectory: _workingDirectory,
      infoLogger: infoLogger,
      warningLogger: warningLogger,
    );

    final FileWriteSummary summary =
        await fileWriter.writeFilesSafely(projectRelativeFiles);

    return FeatureGenerationResult(
      featureRootRelativePath: featureRootRelativePath,
      createdCount: summary.createdCount,
      skippedCount: summary.skippedCount,
      projectCreatedCount: projectScaffoldResult.createdCount,
      projectSkippedCount: projectScaffoldResult.skippedCount,
    );
  }

  /// Selects state template output for [stateManagement].
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  /// - [stateManagement]: Selected state strategy.
  ///
  /// Return value:
  /// - [StateTemplateOutput] for the chosen strategy.
  ///
  /// Possible errors:
  /// - Throws [UnsupportedError] for unsupported enum values.
  StateTemplateOutput _resolveStateTemplateOutput(
    FeatureNaming naming,
    StateManagementType stateManagement,
  ) {
    switch (stateManagement) {
      case StateManagementType.riverpod:
        return RiverpodTemplates.build(naming);
      case StateManagementType.bloc:
        return BlocTemplates.build(naming);
      case StateManagementType.getx:
        return GetxTemplates.build(naming);
      case StateManagementType.provider:
        return ProviderTemplates.build(naming);
    }
  }
}
