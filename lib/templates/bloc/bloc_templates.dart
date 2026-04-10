/// Bloc-specific state and page templates.
///
/// This file builds Cubit-based presentation artifacts.
library;

import '../../generators/naming_convention.dart';
import '../shared/state_template_output.dart';

/// Builds Bloc templates for generated features.
///
/// This builder produces Cubit-based presentation files and associated DI
/// metadata for the selected feature.
class BlocTemplates {
  /// Builds bloc state-management files for [naming].
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - [StateTemplateOutput] containing bloc files and DI metadata.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static StateTemplateOutput build(FeatureNaming naming) {
    return StateTemplateOutput(
      filesByRelativePath: <String, String>{
        'presentation/bloc/${naming.snakeCase}_bloc.dart':
            _buildBlocFile(naming),
        'presentation/pages/${naming.snakeCase}_page.dart':
            _buildPageFile(naming),
      },
      stateClassName: '${naming.pascalCase}Bloc',
      stateFileImportPath: 'presentation/bloc/${naming.snakeCase}_bloc.dart',
      stateFactoryExpression:
          '${naming.pascalCase}Bloc(get${naming.pascalCase}ItemsUseCase: sl())',
    );
  }

  /// Builds the Bloc/Cubit state file template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for `<feature>_bloc.dart`.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildBlocFile(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} Bloc
/// Manages loading/error/data state using Cubit.
/// Layer: Presentation
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/${naming.snakeCase}_entity.dart';
import '../../domain/usecases/get_${naming.snakeCase}_items_use_case.dart';

/// Immutable bloc state for ${naming.titleCase} rendering.
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

  /// Creates initial default state.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Initial [${naming.pascalCase}State] instance.
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

  /// Whether loading is in progress.
  final bool isLoading;

  /// Optional error message.
  final String? errorMessage;

  /// Loaded entities.
  final List<${naming.pascalCase}Entity> items;

  /// Returns a new state with overridden values.
  ///
  /// Parameters:
  /// - [isLoading]: Optional loading override.
  /// - [errorMessage]: Optional error message override.
  /// - [items]: Optional items override.
  ///
  /// Return value:
  /// - Updated immutable [${naming.pascalCase}State].
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

/// Cubit controller for ${naming.titleCase} data lifecycle.
class ${naming.pascalCase}Bloc extends Cubit<${naming.pascalCase}State> {
  /// Creates bloc with required use case dependency.
  ///
  /// Parameters:
  /// - [get${naming.pascalCase}ItemsUseCase]: Use case used to fetch feature items.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}Bloc] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  ${naming.pascalCase}Bloc({
    required Get${naming.pascalCase}ItemsUseCase get${naming.pascalCase}ItemsUseCase,
  })  : _get${naming.pascalCase}ItemsUseCase = get${naming.pascalCase}ItemsUseCase,
        super(${naming.pascalCase}State.initial());

  /// Feature use case dependency.
  final Get${naming.pascalCase}ItemsUseCase _get${naming.pascalCase}ItemsUseCase;

  /// Loads feature items and emits new states.
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
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
    ));

    final result = await _get${naming.pascalCase}ItemsUseCase();

    result.fold(
      onLeft: (failure) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          items: const <${naming.pascalCase}Entity>[],
        ));
      },
      onRight: (data) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: null,
          items: data,
        ));
      },
    );
  }
}
''';
  }

  /// Builds the Bloc-driven page template.
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
/// Builds the ${naming.titleCase} screen using Bloc state.
/// Layer: Presentation
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../${naming.snakeCase}_di.dart';
import '../bloc/${naming.snakeCase}_bloc.dart';
import '../widgets/${naming.snakeCase}_view.dart';

/// Entry page widget for the ${naming.titleCase} feature.
class ${naming.pascalCase}Page extends StatelessWidget {
  /// Creates a Bloc-backed page.
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

  /// Builds UI using bloc state and listeners.
  ///
  /// Parameters:
  /// - [context]: Flutter build context.
  ///
  /// Return value:
  /// - A widget tree bound to bloc-driven state.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<${naming.pascalCase}Bloc>(
      create: (_) => sl<${naming.pascalCase}Bloc>()..load(),
      child: BlocBuilder<${naming.pascalCase}Bloc, ${naming.pascalCase}State>(
        builder: (BuildContext context, ${naming.pascalCase}State state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('${naming.titleCase}'),
            ),
            body: ${naming.pascalCase}View(
              isLoading: state.isLoading,
              errorMessage: state.errorMessage,
              items: state.items,
              onRetry: () => context.read<${naming.pascalCase}Bloc>().load(),
            ),
          );
        },
      ),
    );
  }
}
''';
  }
}
