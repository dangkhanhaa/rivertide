import 'package:rivertide/core/errors/app_exception.dart';

/// Provider retry policy: retry transient failures with backoff, never the
/// deterministic ones (no data here, bad data, no permission) — retrying those
/// only keeps the screen spinning instead of showing the answer.
Duration? providerRetry(int retryCount, Object error) {
  if (error is NotFoundException || error is ParseException || error is PermissionDeniedException) {
    return null;
  }
  if (retryCount >= 4) return null;
  return Duration(milliseconds: 500 * (1 << retryCount));
}
