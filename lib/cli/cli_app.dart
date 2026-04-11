/// CLI command runner for `clean_arch_builder`.
///
/// This file parses command-line arguments, validates input, and delegates
/// generation work to the feature generator.
library;

import 'dart:io';

import 'package:args/args.dart';

import '../generators/feature_generator.dart';
import '../generators/generation_options.dart';
import '../generators/project_scaffold_generator.dart';
import 'help_text.dart';

/// Executes top-level CLI commands for the package.
///
/// This class is the runtime entry-point for argument parsing, command
/// dispatch, input validation, and generator invocation.
class CleanArchBuilderCli {
  /// Creates a CLI runner with optional IO and directory overrides.
  ///
  /// Parameters:
  /// - [workingDirectory]: Base project directory for generated output.
  /// - [stdoutLogger]: Optional logger for standard messages.
  /// - [stderrLogger]: Optional logger for warnings and errors.
  ///
  /// Return value:
  /// - A configured [CleanArchBuilderCli] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  CleanArchBuilderCli({
    Directory? workingDirectory,
    void Function(String message)? stdoutLogger,
    void Function(String message)? stderrLogger,
  })  : _workingDirectory = workingDirectory ?? Directory.current,
        _stdoutLogger =
            stdoutLogger ?? ((String message) => stdout.writeln(message)),
        _stderrLogger =
            stderrLogger ?? ((String message) => stderr.writeln(message));

  /// Directory where feature files are generated.
  final Directory _workingDirectory;

  /// Output callback for informational logs.
  final void Function(String message) _stdoutLogger;

  /// Output callback for warning/error logs.
  final void Function(String message) _stderrLogger;

  /// Runs the CLI using provided [arguments].
  ///
  /// Parameters:
  /// - [arguments]: Raw command-line arguments.
  ///
  /// Return value:
  /// - Exit code `0` on success.
  /// - Non-zero exit code on validation or runtime failure.
  ///
  /// Possible errors:
  /// - Catches and converts known errors to exit codes.
  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty || _isGlobalHelpRequest(arguments)) {
      _stdoutLogger(buildGlobalHelp());
      return 0;
    }

    final String command = arguments.first;
    final List<String> commandArgs =
        arguments.length > 1 ? arguments.sublist(1) : const <String>[];

    switch (command) {
      case 'init':
      case 'setup_project':
        return _runProjectSetup(commandArgs, commandName: command);
      case 'create_feature':
        return _runCreateFeature(commandArgs);
      default:
        _stderrLogger('Unknown command: $command');
        _stdoutLogger(buildGlobalHelp());
        return 64;
    }
  }

  /// Checks whether the invocation requests top-level help.
  ///
  /// Parameters:
  /// - [arguments]: Raw command-line arguments.
  ///
  /// Return value:
  /// - `true` when global help should be shown.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  bool _isGlobalHelpRequest(List<String> arguments) {
    return arguments.length == 1 &&
        (arguments.first == '--help' || arguments.first == '-h');
  }

  /// Handles `create_feature` command parsing and execution.
  ///
  /// What it does:
  /// - Generates a complete feature module and ensures project base scaffold
  ///   files exist before generation.
  ///
  /// When to use it:
  /// - Use this command whenever you want to add a new feature module such as
  ///   `auth`, `profile`, or `settings`.
  ///
  /// Example usage:
  /// - `clean_arch_builder create_feature auth --state=provider --data=rest`
  ///
  /// Parameters:
  /// - [commandArguments]: Arguments that follow `create_feature`.
  ///
  /// Return value:
  /// - Exit code `0` on success.
  /// - Exit code `64` on invalid usage.
  /// - Exit code `74` on filesystem failures.
  /// - Exit code `1` for unexpected failures.
  ///
  /// Possible errors:
  /// - Catches [FormatException], [FileSystemException], and generic exceptions.
  Future<int> _runCreateFeature(List<String> commandArguments) async {
    final ArgParser parser = _buildCreateFeatureParser();
    late ArgResults results;

    try {
      results = parser.parse(commandArguments);
    } on FormatException catch (error) {
      _stderrLogger('Argument error: ${error.message}');
      _stdoutLogger(buildCreateFeatureHelp());
      return 64;
    }

    final bool wantsHelp = results['help'] as bool;
    if (wantsHelp) {
      _stdoutLogger(buildCreateFeatureHelp());
      return 0;
    }

    final List<String> positionalArguments = results.rest;
    if (positionalArguments.isEmpty) {
      _stderrLogger('Missing required argument: <feature_name>.');
      _stdoutLogger(buildCreateFeatureHelp());
      return 64;
    }

    if (positionalArguments.length > 1) {
      _stderrLogger('Only one <feature_name> can be provided.');
      _stdoutLogger(buildCreateFeatureHelp());
      return 64;
    }

    final String featureName = positionalArguments.first;

    try {
      final StateManagementType stateManagement = parseStateManagementType(
        results['state'] as String,
      );
      final DataSourceType dataSource = parseDataSourceType(
        results['data'] as String,
      );

      final FeatureGenerator generator = FeatureGenerator(
        workingDirectory: _workingDirectory,
        infoLogger: _stdoutLogger,
        warningLogger: _stdoutLogger,
      );

      _stdoutLogger('Generating feature "$featureName"...');

      final FeatureGenerationResult generationResult =
          await generator.createFeature(
        featureName,
        GenerationOptions(
          stateManagement: stateManagement,
          dataSource: dataSource,
        ),
      );

      _stdoutLogger(
        'Project scaffold ensured: '
        '${generationResult.projectCreatedCount} file(s) created, '
        '${generationResult.projectSkippedCount} file(s) skipped.',
      );
      _stdoutLogger(
        '✔ Feature created successfully in '
        '${generationResult.featureRootRelativePath}',
      );
      _stdoutLogger(
        'Feature summary: ${generationResult.createdCount} file(s) created, '
        '${generationResult.skippedCount} file(s) skipped.',
      );

      return 0;
    } on FormatException catch (error) {
      _stderrLogger('Input error: ${error.message}');
      return 64;
    } on FileSystemException catch (error) {
      _stderrLogger('File system error: ${error.message}');
      return 74;
    } catch (error) {
      _stderrLogger('Unexpected error: $error');
      return 1;
    }
  }

  /// Handles `init` and `setup_project` command execution.
  ///
  /// What it does:
  /// - Generates reusable project-level files under `lib/config`, `lib/core`,
  ///   and `lib/shared` without overwriting existing files.
  ///
  /// When to use it:
  /// - Run this before creating your first feature or anytime you need to
  ///   restore missing base scaffold files.
  ///
  /// Example usage:
  /// - `clean_arch_builder init`
  /// - `clean_arch_builder setup_project`
  ///
  /// Parameters:
  /// - [commandArguments]: Arguments passed after the command name.
  /// - [commandName]: Actual command alias used by the caller.
  ///
  /// Return value:
  /// - Exit code `0` on success.
  /// - Exit code `64` on invalid usage.
  /// - Exit code `74` on filesystem failures.
  /// - Exit code `1` for unexpected failures.
  ///
  /// Possible errors:
  /// - Catches [FormatException], [FileSystemException], and generic errors.
  Future<int> _runProjectSetup(
    List<String> commandArguments, {
    required String commandName,
  }) async {
    final ArgParser parser = _buildProjectSetupParser();
    late ArgResults results;

    try {
      results = parser.parse(commandArguments);
    } on FormatException catch (error) {
      _stderrLogger('Argument error: ${error.message}');
      _stdoutLogger(buildProjectSetupHelp(commandName));
      return 64;
    }

    final bool wantsHelp = results['help'] as bool;
    if (wantsHelp) {
      _stdoutLogger(buildProjectSetupHelp(commandName));
      return 0;
    }

    if (results.rest.isNotEmpty) {
      _stderrLogger('$commandName does not accept positional arguments.');
      _stdoutLogger(buildProjectSetupHelp(commandName));
      return 64;
    }

    try {
      final ProjectScaffoldGenerator scaffoldGenerator =
          ProjectScaffoldGenerator(
        workingDirectory: _workingDirectory,
        infoLogger: _stdoutLogger,
        warningLogger: _stdoutLogger,
      );

      _stdoutLogger('Initializing reusable project scaffold...');

      final ProjectScaffoldResult scaffoldResult =
          await scaffoldGenerator.initializeProject();

      _stdoutLogger(
        '✔ Project scaffold initialized successfully under '
        'lib/config, lib/core, and lib/shared.',
      );
      _stdoutLogger(
        'Summary: ${scaffoldResult.createdCount} file(s) created, '
        '${scaffoldResult.skippedCount} file(s) skipped.',
      );

      if (scaffoldResult.skippedCount > 0) {
        _stdoutLogger('\n--- Integration Guide ---');
        _stdoutLogger('It looks like some base files (e.g. main.dart) already exist.');
        _stdoutLogger('Please ensure your main.dart is updated to include:');
        _stdoutLogger('1. Route Configuration: onGenerateRoute: AppRoutes.onGenerateRoute');
        _stdoutLogger('2. Theming: theme: AppTheme.lightTheme, darkTheme: AppTheme.darkTheme');
        _stdoutLogger('3. Dependency Injection: await initDependencies(); in main()');
        _stdoutLogger('-------------------------\n');
      }

      return 0;
    } on FileSystemException catch (error) {
      _stderrLogger('File system error: ${error.message}');
      return 74;
    } catch (error) {
      _stderrLogger('Unexpected error: $error');
      return 1;
    }
  }

  /// Builds argument parser for `create_feature` command.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Configured [ArgParser] with command options.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  ArgParser _buildCreateFeatureParser() {
    return ArgParser(allowTrailingOptions: true)
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for create_feature command.',
      )
      ..addOption(
        'state',
        defaultsTo: StateManagementType.riverpod.cliValue,
        allowed: StateManagementType.values
            .map<String>((StateManagementType value) => value.cliValue)
            .toList(growable: false),
        help: 'State management type (riverpod|bloc|getx|provider).',
      )
      ..addOption(
        'data',
        defaultsTo: DataSourceType.rest.cliValue,
        allowed: DataSourceType.values
            .map<String>((DataSourceType value) => value.cliValue)
            .toList(growable: false),
        help: 'Data source type (rest|firebase|local).',
      );
  }

  /// Builds argument parser for `init` and `setup_project`.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Configured [ArgParser] with command options.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  ArgParser _buildProjectSetupParser() {
    return ArgParser(allowTrailingOptions: true)
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Show help for init/setup_project command.',
      );
  }
}
