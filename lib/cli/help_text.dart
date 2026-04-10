/// Help text builders for the `clean_arch_builder` command-line interface.
///
/// This file centralizes user-facing usage and examples for consistent help
/// output across commands.
library;

/// Builds the global CLI help text.
///
/// Parameters:
/// - None.
///
/// Return value:
/// - A formatted multi-line help string describing available commands and
///   options.
///
/// Possible errors:
/// - This function does not throw under normal usage.
String buildGlobalHelp() {
  return '''clean_arch_builder
A Flutter Clean Architecture scaffolding CLI for project and feature generation.

Usage:
  clean_arch_builder <command> [arguments]

Commands:
  init                             Create reusable project scaffold (config/core/shared).
  setup_project                    Alias for init.
  create_feature <feature_name>    Generate a feature module using shared base files.

Global options:
  -h, --help                       Show this help message.

init/setup_project:
  What it does:
    Creates starter files under lib/config, lib/core, and lib/shared.
  When to use it:
    Run before creating your first feature or whenever base files are missing.
  Examples:
    clean_arch_builder init
    clean_arch_builder setup_project

create_feature options:
  --state=<riverpod|bloc|getx|provider>    State management solution. Default: riverpod.
  --data=<rest|firebase|local>             Data source style. Default: rest.
  -h, --help                               Show command-specific help.

create_feature:
  What it does:
    Generates a full feature module and reuses project-level config/core/shared files.
  When to use it:
    Run whenever you add a new business feature.

Examples:
  clean_arch_builder init
  clean_arch_builder create_feature auth
  clean_arch_builder create_feature auth --state=provider --data=rest
  clean_arch_builder create_feature profile --state=bloc --data=firebase
''';
}

/// Builds help text for the `create_feature` command.
///
/// Parameters:
/// - None.
///
/// Return value:
/// - A formatted multi-line help string containing command-specific details.
///
/// Possible errors:
/// - This function does not throw under normal usage.
String buildCreateFeatureHelp() {
  return '''Command: create_feature

What it does:
  Generates a complete Clean Architecture feature module and ensures shared
  project base files are available.

When to use it:
  Use this command when adding a new feature such as auth, profile, or settings.

Usage:
  clean_arch_builder create_feature <feature_name> [options]

Options:
  --state=<riverpod|bloc|getx|provider>
      Select the state management approach.
      Default: riverpod

  --data=<rest|firebase|local>
      Select the data layer source template.
      Default: rest

  -h, --help
      Show this command help.

Examples:
  clean_arch_builder create_feature auth
  clean_arch_builder create_feature auth --state=provider --data=rest
  clean_arch_builder create_feature account_settings --state=getx --data=local
''';
}

/// Builds help text for `init` and `setup_project`.
///
/// Parameters:
/// - [commandName]: Command alias used by the current invocation.
///
/// Return value:
/// - A formatted multi-line help string with setup-specific guidance.
///
/// Possible errors:
/// - This function does not throw under normal usage.
String buildProjectSetupHelp(String commandName) {
  return '''Command: $commandName

What it does:
  Creates reusable base folders and files under:
    - lib/config
    - lib/core
    - lib/shared

When to use it:
  Run this command at project start, or later to recreate missing base files.

Usage:
  clean_arch_builder $commandName

Options:
  -h, --help
      Show this command help.

Examples:
  clean_arch_builder init
  clean_arch_builder setup_project
''';
}
