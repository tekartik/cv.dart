import 'dart:convert';

class _EnumToStringConverter<T extends Enum> with Converter<T, String> {
  const _EnumToStringConverter();
  @override
  String convert(T input) => input.name;
}

class _StringToEnumConverter<T extends Enum> with Converter<String, T> {
  final List<T> values;
  const _StringToEnumConverter(this.values);
  @override
  T convert(String input) => values.byName(input);
}

/// Codec to convert enum to/from string using the enum name.
class EnumToStringCodec<T extends Enum> with Codec<T, String> {
  /// List of enum values.
  final List<T> values;

  /// Create a codec for the given enum values.
  const EnumToStringCodec(this.values);
  @override
  Converter<String, T> get decoder => _StringToEnumConverter<T>(values);

  @override
  Converter<T, String> get encoder => _EnumToStringConverter<T>();
}
