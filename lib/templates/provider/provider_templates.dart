library;

import '../../generators/naming_convention.dart';
import '../shared/state_template_output.dart';

class ProviderTemplates {
  static StateTemplateOutput build(FeatureNaming naming) {
    return StateTemplateOutput(
      filesByRelativePath: <String, String>{
        'presentation/providers/${naming.snakeCase}_provider.dart':
            _buildProviderFile(naming),
        'presentation/pages/${naming.snakeCase}_page.dart':
            _buildPageFile(naming),
      },
      stateClassName: '${naming.pascalCase}Provider',
      stateFileImportPath:
          'presentation/providers/${naming.snakeCase}_provider.dart',
      stateFactoryExpression:
          '${naming.pascalCase}Provider(get${naming.pascalCase}ItemsUseCase: sl())',
    );
  }

  static String _buildProviderFile(FeatureNaming naming) {
    return '''library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/${naming.snakeCase}_entity.dart';
import '../../domain/usecases/get_${naming.snakeCase}_items_use_case.dart';

class ${naming.pascalCase}Provider extends ChangeNotifier {
  // Initializes provider dependency
  ${naming.pascalCase}Provider({
    required Get${naming.pascalCase}ItemsUseCase get${naming.pascalCase}ItemsUseCase,
  }) : _get${naming.pascalCase}ItemsUseCase = get${naming.pascalCase}ItemsUseCase;

  final Get${naming.pascalCase}ItemsUseCase _get${naming.pascalCase}ItemsUseCase;
  bool _isLoading = false;
  String? _errorMessage;
  List<${naming.pascalCase}Entity> _items = const <${naming.pascalCase}Entity>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<${naming.pascalCase}Entity> get items => List<${naming.pascalCase}Entity>.unmodifiable(_items);

  // Loads feature items
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _get${naming.pascalCase}ItemsUseCase();

    result.fold(
      onLeft: (failure) {
        _errorMessage = failure.message;
        _items = const <${naming.pascalCase}Entity>[];
      },
      onRight: (data) {
        _errorMessage = null;
        _items = data;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
''';
  }

  static String _buildPageFile(FeatureNaming naming) {
    return '''library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../${naming.snakeCase}_di.dart';
import '../providers/${naming.snakeCase}_provider.dart';
import '../widgets/${naming.snakeCase}_view.dart';

class ${naming.pascalCase}Page extends StatelessWidget {
  // Initializes feature page
  const ${naming.pascalCase}Page({super.key});

  // Builds provider page UI
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<${naming.pascalCase}Provider>(
      create: (_) => sl<${naming.pascalCase}Provider>()..load(),
      child: Consumer<${naming.pascalCase}Provider>(
        builder: (
          BuildContext context,
          ${naming.pascalCase}Provider controller,
          Widget? child,
        ) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('${naming.titleCase}'),
            ),
            body: ${naming.pascalCase}View(
              isLoading: controller.isLoading,
              errorMessage: controller.errorMessage,
              items: controller.items,
              onRetry: controller.load,
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
