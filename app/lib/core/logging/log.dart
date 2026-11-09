import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// App-wide logger. Never log exact coordinates, tokens, emails or diary text (CLAUDE.md 3.1).
final AppLog log = AppLog._(
  Logger(level: kReleaseMode ? Level.warning : Level.debug, printer: SimplePrinter(colors: false)),
);

class AppLog {
  AppLog._(this._logger);

  final Logger _logger;

  void info(String message, [Map<String, Object?> fields = const {}]) =>
      _logger.i(_format(message, fields));

  void warn(String message, [Map<String, Object?> fields = const {}]) =>
      _logger.w(_format(message, fields));

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  String _format(String message, Map<String, Object?> fields) =>
      fields.isEmpty ? message : '$message $fields';
}
