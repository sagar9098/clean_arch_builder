/// Safe file writing utilities for scaffold generation.
///
/// This file provides no-overwrite file creation behavior so existing code is
/// never replaced unintentionally.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

/// Represents the summary of a bulk file writing operation.
///
/// This model is returned to the CLI layer so user-facing output can clearly
/// report created versus skipped files.
class FileWriteSummary {
  /// Creates a [FileWriteSummary] instance.
  ///
  /// Parameters:
  /// - [createdCount]: Number of files created.
  /// - [skippedCount]: Number of files skipped due to pre-existence.
  ///
  /// Return value:
  /// - A summary object for reporting generation outcomes.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const FileWriteSummary({
    required this.createdCount,
    required this.skippedCount,
  });

  /// Number of newly created files.
  final int createdCount;

  /// Number of files that already existed and were skipped.
  final int skippedCount;
}

/// Writes generated files while preserving existing user files.
///
/// This utility is used by [FeatureGenerator] to guarantee non-destructive
/// scaffolding behavior.
class SafeFileWriter {
  /// Creates a [SafeFileWriter] bound to [rootDirectory].
  ///
  /// Parameters:
  /// - [rootDirectory]: Base directory for all relative writes.
  /// - [infoLogger]: Optional callback for informative logs.
  /// - [warningLogger]: Optional callback for warning logs.
  ///
  /// Return value:
  /// - A configured writer instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const SafeFileWriter({
    required this.rootDirectory,
    this.infoLogger,
    this.warningLogger,
  });

  /// Root location where generated files are written.
  final Directory rootDirectory;

  /// Optional callback for informational output.
  final void Function(String message)? infoLogger;

  /// Optional callback for warning output.
  final void Function(String message)? warningLogger;

  /// Creates all files from [filesByRelativePath] if they do not already exist.
  ///
  /// Parameters:
  /// - [filesByRelativePath]: Map of relative paths to file content.
  ///
  /// Return value:
  /// - A [FileWriteSummary] with created and skipped counts.
  ///
  /// Possible errors:
  /// - Throws [FileSystemException] when directories or files cannot be created.
  Future<FileWriteSummary> writeFilesSafely(
    Map<String, String> filesByRelativePath,
  ) async {
    int createdCount = 0;
    int skippedCount = 0;

    final List<String> orderedPaths = filesByRelativePath.keys.toList()..sort();

    for (final String relativePath in orderedPaths) {
      final File targetFile = File(p.join(rootDirectory.path, relativePath));

      if (await targetFile.exists()) {
        skippedCount += 1;
        warningLogger?.call('⚠ Skipped existing file: $relativePath');
        continue;
      }

      await targetFile.parent.create(recursive: true);
      await targetFile.writeAsString(filesByRelativePath[relativePath]!);

      createdCount += 1;
      infoLogger?.call('✔ Created: $relativePath');
    }

    return FileWriteSummary(
      createdCount: createdCount,
      skippedCount: skippedCount,
    );
  }
}
