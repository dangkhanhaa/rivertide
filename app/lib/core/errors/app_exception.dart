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

final class RateLimitedException extends AppException {
  const RateLimitedException(super.debugMessage);
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
