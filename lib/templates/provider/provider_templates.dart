/// Provider-specific state and page templates.
///
/// This file builds `ChangeNotifier`-based presentation artifacts.
library;

import '../../generators/naming_convention.dart';
import '../shared/state_template_output.dart';

/// Builds Provider templates for generated features.
///
/// This builder produces `ChangeNotifier`-based presentation files and
/// associated DI metadata for the selected feature.
class ProviderTemplates {
  /// Builds provider state-management files for [naming].
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - [StateTemplateOutput] containing provider files and DI metadata.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
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

  /// Builds the Provider `ChangeNotifier` template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for `<feature>_provider.dart`.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildProviderFile(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} Provider
/// Manages loading/error/data state using `ChangeNotifier`.
/// Layer: Presentation
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/${naming.snakeCase}_entity.dart';
import '../../domain/usecases/get_${naming.snakeCase}_items_use_case.dart';

/// Provider controller for ${naming.titleCase} feature state.
class ${naming.pascalCase}Provider extends ChangeNotifier {
  /// Creates a provider with required use case dependency.
  ///
  /// Parameters:
  /// - [get${naming.pascalCase}ItemsUseCase]: Use case used to fetch feature data.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}Provider] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  ${naming.pascalCase}Provider({
    required Get${naming.pascalCase}ItemsUseCase get${naming.pascalCase}ItemsUseCase,
  }) : _get${naming.pascalCase}ItemsUseCase = get${naming.pascalCase}ItemsUseCase;

  /// Use case used to load ${naming.titleCase} items.
  final Get${naming.pascalCase}ItemsUseCase _get${naming.pascalCase}ItemsUseCase;

  /// Backing loading flag.
  bool _isLoading = false;

  /// Backing error message.
  String? _errorMessage;

  /// Backing list of loaded entities.
  List<${naming.pascalCase}Entity> _items = const <${naming.pascalCase}Entity>[];

  /// Exposes whether a load request is currently running.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - `true` while the provider is waiting for use-case completion.
  ///
  /// Possible errors:
  /// - This getter does not throw under normal usage.
  bool get isLoading => _isLoading;

  /// Exposes the latest user-visible error message, when available.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Error text when loading fails, otherwise `null`.
  ///
  /// Possible errors:
  /// - This getter does not throw under normal usage.
  String? get errorMessage => _errorMessage;

  /// Exposes an immutable snapshot of currently loaded entities.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Unmodifiable list of feature entities.
  ///
  /// Possible errors:
  /// - This getter does not throw under normal usage.
  List<${naming.pascalCase}Entity> get items => List<${naming.pascalCase}Entity>.unmodifiable(_items);

  /// Loads ${naming.titleCase} items and updates UI state.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Completes when loading finishes.
  ///
  /// Possible errors:
  /// - Converts domain failures to [errorMessage] instead of throwing.
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

  /// Clears the current error message and notifies listeners.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - None.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
''';
  }

  /// Builds the Provider-driven page template.
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
/// Provides screen composition using Provider and feature DI.
/// Layer: Presentation
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../${naming.snakeCase}_di.dart';
import '../providers/${naming.snakeCase}_provider.dart';
import '../widgets/${naming.snakeCase}_view.dart';

/// Entry page widget for the ${naming.titleCase} feature.
class ${naming.pascalCase}Page extends StatelessWidget {
  /// Creates a page for ${naming.titleCase}.
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

  /// Builds the provider-backed screen.
  ///
  /// Parameters:
  /// - [context]: Flutter build context.
  ///
  /// Return value:
  /// - A widget tree that binds provider state to view rendering.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
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
