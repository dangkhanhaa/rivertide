/// Build-time configuration from `--dart-define=ENV=<env>`.
///
/// V0 has no server and no secrets: the base map (OpenFreeMap) needs no key.
abstract final class Env {
  static const String name = String.fromEnvironment('ENV', defaultValue: 'dev');

  /// App version shown to users (keep in step with pubspec.yaml).
  static const String version = '0.1.0';

  /// Commit the web build was made from (CI: --dart-define=BUILD_SHA=...);
  /// empty in local builds, which then never report an update.
  static const String buildSha = String.fromEnvironment('BUILD_SHA');
}
