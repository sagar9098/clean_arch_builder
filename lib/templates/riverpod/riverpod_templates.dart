library;

import '../../generators/naming_convention.dart';
import '../shared/state_template_output.dart';

class RiverpodTemplates {
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

  static String _buildRiverpodFile(FeatureNaming naming) {
    return '''library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../${naming.snakeCase}_di.dart';
import '../../domain/entities/${naming.snakeCase}_entity.dart';
import '../../domain/usecases/get_${naming.snakeCase}_items_use_case.dart';

class ${naming.pascalCase}State {
  // Initializes state payload
  const ${naming.pascalCase}State({
    required this.isLoading,
    required this.errorMessage,
    required this.items,
  });

  // Creates default state
  factory ${naming.pascalCase}State.initial() {
    return const ${naming.pascalCase}State(
      isLoading: false,
      errorMessage: null,
      items: <${naming.pascalCase}Entity>[],
    );
  }

  final bool isLoading;
  final String? errorMessage;
  final List<${naming.pascalCase}Entity> items;
  // Copies state values
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

class ${naming.pascalCase}Notifier extends StateNotifier<${naming.pascalCase}State> {
  // Initializes notifier dependency
  ${naming.pascalCase}Notifier({
    required Get${naming.pascalCase}ItemsUseCase get${naming.pascalCase}ItemsUseCase,
  })  : _get${naming.pascalCase}ItemsUseCase = get${naming.pascalCase}ItemsUseCase,
        super(${naming.pascalCase}State.initial());

  final Get${naming.pascalCase}ItemsUseCase _get${naming.pascalCase}ItemsUseCase;
  // Loads feature items
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

final StateNotifierProvider<${naming.pascalCase}Notifier, ${naming.pascalCase}State>
    ${naming.camelCase}Provider =
    StateNotifierProvider<${naming.pascalCase}Notifier, ${naming.pascalCase}State>((Ref ref) {
  return sl<${naming.pascalCase}Notifier>()..load();
});
''';
  }

  static String _buildPageFile(FeatureNaming naming) {
    return '''library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/${naming.snakeCase}_riverpod.dart';
import '../widgets/${naming.snakeCase}_view.dart';

class ${naming.pascalCase}Page extends ConsumerWidget {
  // Initializes feature page
  const ${naming.pascalCase}Page({super.key});
  // Builds riverpod page UI
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
