/// Feature naming utilities used to derive code-safe identifiers.
///
/// This file normalizes user input into multiple naming styles used across
/// generated files, classes, and members.
library;

/// Represents normalized name variants for a feature module.
///
/// This type is used by the generator layer to derive directory names, class
/// names, method names, and readable UI labels from a single CLI input.
class FeatureNaming {
  /// Creates a [FeatureNaming] from a raw user-provided feature name.
  ///
  /// Parameters:
  /// - [rawInput]: Original feature name from CLI input.
  ///
  /// Return value:
  /// - A normalized [FeatureNaming] with snake, camel, and Pascal variants.
  ///
  /// Possible errors:
  /// - Throws [FormatException] when [rawInput] is empty after normalization.
  factory FeatureNaming.fromRaw(String rawInput) {
    final List<String> parts = _splitIntoWords(rawInput);

    if (parts.isEmpty) {
      throw const FormatException(
        'Feature name must contain at least one alphanumeric character.',
      );
    }

    final List<String> normalizedParts = parts
        .map((String item) => item.toLowerCase())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);

    if (normalizedParts.isEmpty) {
      throw const FormatException(
        'Feature name normalization produced no usable tokens.',
      );
    }

    final String snakeCase = normalizedParts.join('_');
    final String pascalCase =
        normalizedParts.map<String>((String item) => _capitalize(item)).join();
    final String camelCase =
        '${normalizedParts.first}${pascalCase.substring(normalizedParts.first.length)}';

    return FeatureNaming._(
      rawInput: rawInput,
      words: normalizedParts,
      snakeCase: snakeCase,
      pascalCase: pascalCase,
      camelCase: camelCase,
    );
  }

  /// Internal constructor used by [FeatureNaming.fromRaw].
  ///
  /// Parameters:
  /// - [rawInput]: Original feature name from CLI input.
  /// - [words]: Normalized lowercase words.
  /// - [snakeCase]: Snake-case representation.
  /// - [pascalCase]: Pascal-case representation.
  /// - [camelCase]: Camel-case representation.
  ///
  /// Return value:
  /// - A configured [FeatureNaming] instance.
  ///
  /// Possible errors:
  /// - This constructor does not throw under normal usage.
  const FeatureNaming._({
    required this.rawInput,
    required this.words,
    required this.snakeCase,
    required this.pascalCase,
    required this.camelCase,
  });

  /// The original CLI input.
  final String rawInput;

  /// Normalized lowercase words extracted from [rawInput].
  final List<String> words;

  /// Feature name in snake_case.
  final String snakeCase;

  /// Feature name in PascalCase.
  final String pascalCase;

  /// Feature name in camelCase.
  final String camelCase;

  /// Builds the feature name in human-readable title case.
  ///
  /// Parameters:
  /// - None.
  ///
  /// Return value:
  /// - A space-separated title string such as `Account Settings`.
  ///
  /// Possible errors:
  /// - This getter does not throw under normal usage.
  String get titleCase => words.map<String>(_capitalize).join(' ');

  /// Splits [input] into normalized word tokens.
  ///
  /// Parameters:
  /// - [input]: Arbitrary user input that may include separators or casing.
  ///
  /// Return value:
  /// - A list of extracted token candidates.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static List<String> _splitIntoWords(String input) {
    final String withUnderscores =
        input.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_').replaceAllMapped(
              RegExp(r'([a-z])([A-Z])'),
              (Match match) => '${match.group(1)}_${match.group(2)}',
            );

    return withUnderscores
        .split('_')
        .map((String token) => token.trim())
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);
  }

  /// Capitalizes the first character in [value].
  ///
  /// Parameters:
  /// - [value]: Lowercase or mixed-case input word.
  ///
  /// Return value:
  /// - Word with an uppercase first character.
  ///
  /// Possible errors:
  /// - This method does not throw under normal usage.
  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
