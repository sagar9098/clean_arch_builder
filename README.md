# clean_arch_builder

`clean_arch_builder` is a production-ready Dart CLI package for generating Flutter Clean Architecture projects and feature modules.

## Description

The tool supports two workflows:
- Initialize reusable project-level scaffold files (`config`, `core`, `shared`)
- Generate feature modules that automatically reuse those shared files

This keeps features lightweight and avoids duplicated boilerplate.

## Features

- Project initialization commands:
  - `init`
  - `setup_project` (alias)
- Feature generation command:
  - `create_feature <feature_name>`
- State management support:
  - `riverpod`
  - `bloc`
  - `getx`
  - `provider`
- Data source support:
  - `rest`
  - `firebase`
  - `local`
- Safe file creation (no overwrite)
- Auto naming conversion (`auth` -> `Auth`, `auth_repository.dart`, etc.)


## Installation

### From pub.dev (after publish)

```bash
dart pub global activate clean_arch_builder
```

### From local source

```bash
dart pub global activate --source path .
```

## Quick Start

1. Initialize shared project scaffold:

```bash
clean_arch_builder init
```

2. Create a feature:

```bash
clean_arch_builder create_feature auth --state=provider --data=rest
```

`create_feature` also auto-ensures base scaffold files if missing.

## CLI Commands

### `clean_arch_builder init`

What it does:
- Creates reusable base files under `lib/config`, `lib/core`, and `lib/shared`.

When to use it:
- Before creating your first feature.
- Any time base files are missing.

Example:

```bash
clean_arch_builder init
```

### `clean_arch_builder setup_project`

Alias for `init`.

Example:

```bash
clean_arch_builder setup_project
```

### `clean_arch_builder create_feature <feature_name> [options]`

What it does:
- Generates a complete feature module under `lib/features/<feature_name>`.
- Reuses project-level base files from `config/core/shared`.

When to use it:
- Whenever you add a new business feature.

Options:
- `--state=riverpod|bloc|getx|provider` (default: `riverpod`)
- `--data=rest|firebase|local` (default: `rest`)

Examples:

```bash
clean_arch_builder create_feature auth
clean_arch_builder create_feature auth --state=provider --data=rest
clean_arch_builder create_feature profile --state=bloc --data=firebase
```

### `clean_arch_builder --help`

Displays:
- all commands
- command descriptions
- usage examples

## Generated Project Scaffold (`init`)

```text
lib/
 ├── config/
 │   ├── app_config.dart
 │   ├── env_config.dart
 │   └── routes.dart
 │
 ├── core/
 │   ├── constants/app_constants.dart
 │   ├── error/
 │   │   ├── exceptions.dart
 │   │   └── failure.dart
 │   ├── network/api_client.dart
 │   ├── result/either.dart
 │   └── utils/logger.dart
 │
 └── shared/
     ├── helpers/validators.dart
     ├── theme/app_theme.dart
     └── widgets/
         ├── custom_button.dart
         └── custom_loader.dart
```

## Generated Feature Structure

Example (`create_feature auth --state=provider --data=rest`):

```text
lib/features/auth/
 ├── data/
 │   ├── datasources/
 │   │   └── auth_rest_data_source.dart
 │   ├── models/
 │   │   └── auth_model.dart
 │   └── repositories/
 │       └── auth_repository_impl.dart
 │
 ├── domain/
 │   ├── entities/
 │   │   └── auth_entity.dart
 │   ├── repositories/
 │   │   └── auth_repository.dart
 │   └── usecases/
 │       └── get_auth_items_use_case.dart
 │
 ├── presentation/
 │   ├── pages/
 │   │   └── auth_page.dart
 │   ├── providers/
 │   │   └── auth_provider.dart
 │   └── widgets/
 │       └── auth_view.dart
 │
 └── auth_di.dart
```

## Reuse Rules in Generated Features

Generated features import and reuse base files:
- `core/error/failure.dart` for error handling
- `core/network/api_client.dart` for REST API calls
- `shared/widgets` for UI components
- `shared/helpers/validators.dart` for validation helpers
- `config/app_config.dart` for base URL and API version

## Architecture Notes

- Domain layer remains pure Dart.
- Data layer handles mapping and exception-to-failure conversion.
- Presentation layer stays focused on feature-specific UI state.
- Shared/core/config files prevent duplicated cross-feature logic.

## Development

```bash
dart pub get
dart analyze
```

## Contribution Guide

1. Fork repository.
2. Create a branch.
3. Update CLI or templates with full `///` docs.
4. Run:
   - `dart pub get`
   - `dart analyze`
5. Open a pull request with command examples and generated output notes.

## License

MIT License. See [LICENSE](LICENSE).
