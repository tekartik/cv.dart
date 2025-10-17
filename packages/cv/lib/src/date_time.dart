import 'dart:convert';

class _DateTimeToStringConverter with Converter<DateTime, String> {
  const _DateTimeToStringConverter();
  @override
  String convert(DateTime input) => input.toIso8601String();
}

class _StringToDateTimeConverter with Converter<String, DateTime> {
  const _StringToDateTimeConverter();
  @override
  DateTime convert(String input) => DateTime.parse(input);
}

/// Codec to convert dateTime to/from string using the dateTime name.
class DateTimeToStringCodec with Codec<DateTime, String> {
  /// Create a codec for the given dateTime values.
  const DateTimeToStringCodec();
  @override
  Converter<String, DateTime> get decoder => const _StringToDateTimeConverter();

  @override
  Converter<DateTime, String> get encoder => const _DateTimeToStringConverter();
}
