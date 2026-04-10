library;

import '../../generators/naming_convention.dart';
import '../shared/state_template_output.dart';

class GetxTemplates {
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

  static String _buildControllerFile(FeatureNaming naming) {
    return '''library;

import 'package:get/get.dart';

import '../../domain/entities/${naming.snakeCase}_entity.dart';
import '../../domain/usecases/get_${naming.snakeCase}_items_use_case.dart';

class ${naming.pascalCase}Controller extends GetxController {
  // Initializes controller dependency
  ${naming.pascalCase}Controller({
    required Get${naming.pascalCase}ItemsUseCase get${naming.pascalCase}ItemsUseCase,
  }) : _get${naming.pascalCase}ItemsUseCase = get${naming.pascalCase}ItemsUseCase;

  final Get${naming.pascalCase}ItemsUseCase _get${naming.pascalCase}ItemsUseCase;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxList<${naming.pascalCase}Entity> items = <${naming.pascalCase}Entity>[].obs;
  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;
  // Loads feature items
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

  static String _buildPageFile(FeatureNaming naming) {
    return '''library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../${naming.snakeCase}_di.dart';
import '../getx/${naming.snakeCase}_controller.dart';
import '../widgets/${naming.snakeCase}_view.dart';

class ${naming.pascalCase}Page extends StatelessWidget {
  // Initializes feature page
  const ${naming.pascalCase}Page({super.key});
  // Builds getx page UI
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
