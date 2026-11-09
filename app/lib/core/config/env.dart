/// Build-time configuration from `--dart-define=ENV=<env>`.
///
/// V0 has no server and no secrets: the base map (OpenFreeMap) needs no key.
abstract final class Env {
  static const String name = String.fromEnvironment('ENV', defaultValue: 'dev');
}
