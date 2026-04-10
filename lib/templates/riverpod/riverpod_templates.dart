/// Riverpod-specific state and page templates.
///
/// This file builds `StateNotifier`-based presentation artifacts.
library;

import '../../generators/naming_convention.dart';
import '../shared/state_template_output.dart';

/// Builds Riverpod templates for generated features.
///
/// This builder produces `StateNotifier`-based presentation files and
/// associated DI metadata for the selected feature.
class RiverpodTemplates {
  /// Builds riverpod state-management files for [naming].
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - [StateTemplateOutput] containing riverpod files and DI metadata.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static StateTemplateOutput build(FeatureNaming naming) {
    return StateTemplateOutput(
      filesByRelativePath: <String, String>{
        'presentation/providers/${naming.snakeCase}_riverpod.dart':
            _buildRiverpodFile(naming),
        'presentation/pages/${naming.snakeCase}_page.dart':
            _buildPageFile(naming),
      },
      stateClassName: '${naming.pascalCase}Notifier',
      stateFileImportPath:
          'presentation/providers/${naming.snakeCase}_riverpod.dart',
      stateFactoryExpression:
          '${naming.pascalCase}Notifier(get${naming.pascalCase}ItemsUseCase: sl())',
    );
  }

  /// Builds the Riverpod `StateNotifier` template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for the riverpod state file.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildRiverpodFile(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} Riverpod State
/// Manages loading/error/data state using StateNotifier.
/// Layer: Presentation
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../${naming.snakeCase}_di.dart';
import '../../domain/entities/${naming.snakeCase}_entity.dart';
import '../../domain/usecases/get_${naming.snakeCase}_items_use_case.dart';

/// Immutable UI state for ${naming.titleCase} page rendering.
class ${naming.pascalCase}State {
  /// Creates a fully defined state instance.
  ///
  /// Parameters:
  /// - [isLoading]: Loading indicator value.
  /// - [errorMessage]: Optional error text.
  /// - [items]: Loaded entities.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}State] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ${naming.pascalCase}State({
    required this.isLoading,
    required this.errorMessage,
    required this.items,
  });

  /// Creates the default initial state.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Initial [${naming.pascalCase}State].
  ///
  /// Possible errors:
  /// - This factory does not throw under normal usage.
  factory ${naming.pascalCase}State.initial() {
    return const ${naming.pascalCase}State(
      isLoading: false,
      errorMessage: null,
      items: <${naming.pascalCase}Entity>[],
    );
  }

  /// Whether data loading is in progress.
  final bool isLoading;

  /// Optional error message.
  final String? errorMessage;

  /// Loaded entities.
  final List<${naming.pascalCase}Entity> items;

  /// Returns a new state with overridden fields.
  ///
  /// Parameters:
  /// - [isLoading]: Optional override for loading state.
  /// - [errorMessage]: Optional override for error message.
  /// - [items]: Optional override for item list.
  ///
  /// Return value:
  /// - A copied [${naming.pascalCase}State] with updated values.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  ${naming.pascalCase}State copyWith({
    bool? isLoading,
    String? errorMessage,
    List<${naming.pascalCase}Entity>? items,
  }) {
    return ${naming.pascalCase}State(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      items: items ?? this.items,
    );
  }
}

/// State notifier for ${naming.titleCase} data lifecycle.
class ${naming.pascalCase}Notifier extends StateNotifier<${naming.pascalCase}State> {
  /// Creates a notifier with required use case dependency.
  ///
  /// Parameters:
  /// - [get${naming.pascalCase}ItemsUseCase]: Use case used to fetch data.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}Notifier] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  ${naming.pascalCase}Notifier({
    required Get${naming.pascalCase}ItemsUseCase get${naming.pascalCase}ItemsUseCase,
  })  : _get${naming.pascalCase}ItemsUseCase = get${naming.pascalCase}ItemsUseCase,
        super(${naming.pascalCase}State.initial());

  /// Feature use case dependency.
  final Get${naming.pascalCase}ItemsUseCase _get${naming.pascalCase}ItemsUseCase;

  /// Loads items and updates immutable state.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Completes when loading finishes.
  ///
  /// Possible errors:
  /// - Converts failures to state instead of throwing.
  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    final result = await _get${naming.pascalCase}ItemsUseCase();

    result.fold(
      onLeft: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          items: const <${naming.pascalCase}Entity>[],
        );
      },
      onRight: (data) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          items: data,
        );
      },
    );
  }
}

/// Riverpod provider exposed to the UI layer.
final StateNotifierProvider<${naming.pascalCase}Notifier, ${naming.pascalCase}State>
    ${naming.camelCase}Provider =
    StateNotifierProvider<${naming.pascalCase}Notifier, ${naming.pascalCase}State>((Ref ref) {
  return sl<${naming.pascalCase}Notifier>()..load();
});
''';
  }

  /// Builds the Riverpod-driven page template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for `<feature>_page.dart`.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildPageFile(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} Page
/// Builds the ${naming.titleCase} screen using Riverpod state.
/// Layer: Presentation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/${naming.snakeCase}_riverpod.dart';
import '../widgets/${naming.snakeCase}_view.dart';

/// Entry page widget for the ${naming.titleCase} feature.
class ${naming.pascalCase}Page extends ConsumerWidget {
  /// Creates a Riverpod-backed ${naming.pascalCase} page.
  ///
  /// Parameters:
  /// - [key]: Optional widget key.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}Page] widget.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const ${naming.pascalCase}Page({super.key});

  /// Builds UI using watched provider state.
  ///
  /// Parameters:
  /// - [context]: Flutter build context.
  /// - [ref]: Riverpod widget reference.
  ///
  /// Return value:
  /// - A widget tree that reflects current provider state.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ${naming.pascalCase}State state = ref.watch(${naming.camelCase}Provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('${naming.titleCase}'),
      ),
      body: ${naming.pascalCase}View(
        isLoading: state.isLoading,
        errorMessage: state.errorMessage,
        items: state.items,
        onRetry: () => ref.read(${naming.camelCase}Provider.notifier).load(),
      ),
    );
  }
}
''';
  }
}
