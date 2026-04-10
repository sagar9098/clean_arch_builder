/// Project scaffold generator.
///
/// This file creates reusable base folders and files under `lib/config`,
/// `lib/core`, and `lib/shared`.
library;

import 'dart:io';

import '../templates/shared/project_templates.dart';
import 'safe_file_writer.dart';

/// Summary for project scaffold generation operations.
class ProjectScaffoldResult {
  /// Creates a project scaffold summary.
  ///
  /// Parameters:
  /// - [createdCount]: Number of files created.
  /// - [skippedCount]: Number of files skipped because they already existed.
  ///
  /// Return value:
  /// - A configured [ProjectScaffoldResult] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ProjectScaffoldResult({
    required this.createdCount,
    required this.skippedCount,
  });

  /// Number of created files.
  final int createdCount;

  /// Number of skipped files.
  final int skippedCount;
}

/// Creates reusable project-level scaffold files.
class ProjectScaffoldGenerator {
  /// Creates a scaffold generator bound to [workingDirectory].
  ///
  /// Parameters:
  /// - [workingDirectory]: Target project root.
  /// - [infoLogger]: Optional informational logger.
  /// - [warningLogger]: Optional warning logger.
  ///
  /// Return value:
  /// - A configured [ProjectScaffoldGenerator] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  ProjectScaffoldGenerator({
    Directory? workingDirectory,
    this.infoLogger,
    this.warningLogger,
  }) : _workingDirectory = workingDirectory ?? Directory.current;

  /// Target project root where files are generated.
  final Directory _workingDirectory;

  /// Optional callback for informational output.
  final void Function(String message)? infoLogger;

  /// Optional callback for warning output.
  final void Function(String message)? warningLogger;

  /// Initializes reusable project scaffold files.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - A [ProjectScaffoldResult] with created and skipped totals.
  ///
  /// Possible errors:
  /// - Throws [FileSystemException] when files cannot be created.
  Future<ProjectScaffoldResult> initializeProject() async {
    final SafeFileWriter fileWriter = SafeFileWriter(
      rootDirectory: _workingDirectory,
      infoLogger: infoLogger,
      warningLogger: warningLogger,
    );

    final FileWriteSummary summary = await fileWriter.writeFilesSafely(
      ProjectTemplates.buildProjectFiles(),
    );

    return ProjectScaffoldResult(
      createdCount: summary.createdCount,
      skippedCount: summary.skippedCount,
    );
  }
}
