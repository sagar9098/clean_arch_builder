library;

import '../../generators/naming_convention.dart';
import '../shared/state_template_output.dart';

class BlocTemplates {
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

  static String _buildBlocFile(FeatureNaming naming) {
    return '''library;

import 'package:flutter_bloc/flutter_bloc.dart';

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

class ${naming.pascalCase}Bloc extends Cubit<${naming.pascalCase}State> {
  // Initializes bloc dependency
  ${naming.pascalCase}Bloc({
    required Get${naming.pascalCase}ItemsUseCase get${naming.pascalCase}ItemsUseCase,
  })  : _get${naming.pascalCase}ItemsUseCase = get${naming.pascalCase}ItemsUseCase,
        super(${naming.pascalCase}State.initial());

  final Get${naming.pascalCase}ItemsUseCase _get${naming.pascalCase}ItemsUseCase;
  // Loads feature items
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

  static String _buildPageFile(FeatureNaming naming) {
    return '''library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../${naming.snakeCase}_di.dart';
import '../bloc/${naming.snakeCase}_bloc.dart';
import '../widgets/${naming.snakeCase}_view.dart';

class ${naming.pascalCase}Page extends StatelessWidget {
  // Initializes feature page
  const ${naming.pascalCase}Page({super.key});
  // Builds bloc page UI
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
