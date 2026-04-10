/// `clean_arch_builder` public library entry point.
///
/// This library exports the CLI interface used by both the executable and
/// programmatic integrations.
library clean_arch_builder;

export 'cli/cli_app.dart';
export 'generators/generation_options.dart';
export 'generators/project_scaffold_generator.dart';
