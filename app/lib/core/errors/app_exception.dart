/// The single error type crossing layer boundaries (docs/rules/01 §5).
sealed class AppException implements Exception {
  const AppException(this.debugMessage);

  /// For logs only; never shown to users and never contains personal data.
  final String debugMessage;

  @override
  String toString() => 'AppException: $debugMessage';
}

final class NetworkException extends AppException {
  const NetworkException(super.debugMessage);
}

final class TimeoutAppException extends AppException {
  const TimeoutAppException(super.debugMessage);
}

final class ServerException extends AppException {
  const ServerException(super.debugMessage, {this.code});
  final String? code;
}

/// Which limit was hit (server detail, P2-54); [other] = a feature's own rule
/// such as "one pond report per 30 minutes", or an older server.
enum RateLimitKind { burst, daily, newDevice, other }

final class RateLimitedException extends AppException {
  const RateLimitedException(super.debugMessage, {this.kind = RateLimitKind.other});
  final RateLimitKind kind;
}

/// The server refused a text (link, phone, offensive words…, P2-54).
/// [reason] is the server's code, e.g. 'link', 'phone', 'repeat'.
final class ContentBlockedException extends AppException {
  const ContentBlockedException(super.debugMessage, {required this.reason});
  final String reason;
}

/// This device may not post until [until] (UTC), after content of it was hidden
/// by many reports (P2-54). Null when the server sent no date.
final class BannedException extends AppException {
  const BannedException(super.debugMessage, {this.until});
  final DateTime? until;
}

final class NotFoundException extends AppException {
  const NotFoundException(super.debugMessage);
}

final class ParseException extends AppException {
  const ParseException(super.debugMessage);
}

final class PermissionDeniedException extends AppException {
  const PermissionDeniedException(super.debugMessage);
}

final class OfflineNoCacheException extends AppException {
  const OfflineNoCacheException(super.debugMessage);
}

/// The item already exists (e.g. a pond within 80 m); [existingId] points to it.
final class DuplicateException extends AppException {
  const DuplicateException(super.debugMessage, {this.existingId});
  final String? existingId;
}
