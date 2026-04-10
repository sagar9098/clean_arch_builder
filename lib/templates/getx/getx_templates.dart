/// GetX-specific state and page templates.
///
/// This file builds GetX controller/reactive presentation artifacts.
library;

import '../../generators/naming_convention.dart';
import '../shared/state_template_output.dart';

/// Builds GetX templates for generated features.
///
/// This builder produces GetX controller-based presentation files and
/// associated DI metadata for the selected feature.
class GetxTemplates {
  /// Builds getx state-management files for [naming].
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - [StateTemplateOutput] containing getx files and DI metadata.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static StateTemplateOutput build(FeatureNaming naming) {
    return StateTemplateOutput(
      filesByRelativePath: <String, String>{
        'presentation/getx/${naming.snakeCase}_controller.dart':
            _buildControllerFile(naming),
        'presentation/pages/${naming.snakeCase}_page.dart':
            _buildPageFile(naming),
      },
      stateClassName: '${naming.pascalCase}Controller',
      stateFileImportPath:
          'presentation/getx/${naming.snakeCase}_controller.dart',
      stateFactoryExpression:
          '${naming.pascalCase}Controller(get${naming.pascalCase}ItemsUseCase: sl())',
    );
  }

  /// Builds the GetX controller template.
  ///
  /// Parameters:
  /// - [naming]: Feature naming variants.
  ///
  /// Return value:
  /// - File content for `<feature>_controller.dart`.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _buildControllerFile(FeatureNaming naming) {
    return '''/// ${naming.pascalCase} GetX Controller
/// Manages loading/error/data state using GetX reactive primitives.
/// Layer: Presentation
library;

import 'package:get/get.dart';

import '../../domain/entities/${naming.snakeCase}_entity.dart';
import '../../domain/usecases/get_${naming.snakeCase}_items_use_case.dart';

/// Reactive controller for ${naming.titleCase} feature state.
class ${naming.pascalCase}Controller extends GetxController {
  /// Creates a controller with required use case dependency.
  ///
  /// Parameters:
  /// - [get${naming.pascalCase}ItemsUseCase]: Use case used to fetch feature data.
  ///
  /// Return value:
  /// - A configured [${naming.pascalCase}Controller] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  ${naming.pascalCase}Controller({
    required Get${naming.pascalCase}ItemsUseCase get${naming.pascalCase}ItemsUseCase,
  }) : _get${naming.pascalCase}ItemsUseCase = get${naming.pascalCase}ItemsUseCase;

  /// Feature use case dependency.
  final Get${naming.pascalCase}ItemsUseCase _get${naming.pascalCase}ItemsUseCase;

  /// Whether loading is in progress.
  final RxBool isLoading = false.obs;

  /// Optional error message.
  final RxnString errorMessage = RxnString();

  /// Loaded entities.
  final RxList<${naming.pascalCase}Entity> items = <${naming.pascalCase}Entity>[].obs;

  /// Internal marker to avoid duplicate auto-load calls.
  bool _hasLoadedOnce = false;

  /// Indicates whether an initial load attempt has already been triggered.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - `true` after [load] has been called at least once.
  ///
  /// Possible errors:
  /// - This getter does not throw under normal usage.
  bool get hasLoadedOnce => _hasLoadedOnce;

  /// Loads items and updates reactive fields.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - Completes when loading finishes.
  ///
  /// Possible errors:
  /// - Converts failures to [errorMessage] values instead of throwing.
  Future<void> load() async {
    _hasLoadedOnce = true;
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _get${naming.pascalCase}ItemsUseCase();

    result.fold(
      onLeft: (failure) {
        errorMessage.value = failure.message;
        items.assignAll(const <${naming.pascalCase}Entity>[]);
      },
      onRight: (data) {
        errorMessage.value = null;
        items.assignAll(data);
      },
    );

    isLoading.value = false;
  }
}
''';
  }

  /// Builds the GetX-driven page template.
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
/// Builds the ${naming.titleCase} screen using GetX reactive state.
/// Layer: Presentation
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../${naming.snakeCase}_di.dart';
import '../getx/${naming.snakeCase}_controller.dart';
import '../widgets/${naming.snakeCase}_view.dart';

/// Entry page widget for the ${naming.titleCase} feature.
class ${naming.pascalCase}Page extends StatelessWidget {
  /// Creates a GetX-backed page widget.
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

  /// Builds UI using reactive controller state.
  ///
  /// Parameters:
  /// - [context]: Flutter build context.
  ///
  /// Return value:
  /// - A widget tree bound to GetX observables.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  @override
  Widget build(BuildContext context) {
    final ${naming.pascalCase}Controller controller = sl<${naming.pascalCase}Controller>();

    if (!controller.hasLoadedOnce) {
      controller.load();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('${naming.titleCase}'),
      ),
      body: Obx(
        () => ${naming.pascalCase}View(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value,
          items: controller.items,
          onRetry: controller.load,
        ),
      ),
    );
  }
}
''';
  }
}
