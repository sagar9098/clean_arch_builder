/// Entry point for the `clean_arch_builder` executable.
///
/// This file delegates argument handling and command execution to
/// [CleanArchBuilderCli].
library;

import 'dart:io';

import 'package:clean_arch_builder/clean_arch_builder.dart';

/// Runs the CLI application with the received command-line [arguments].
///
/// Parameters:
/// - [arguments]: Command-line arguments passed by the operating system.
///
/// Return value:
/// - Completes when command execution is finished.
///
/// Possible errors:
/// - Exits with a non-zero process code when command processing fails.
Future<void> main(List<String> arguments) async {
  final CleanArchBuilderCli cli = CleanArchBuilderCli();
  final int exitCode = await cli.run(arguments);

  if (exitCode != 0) {
    exit(exitCode);
  }
}
