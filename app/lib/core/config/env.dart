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

  /// Public web app; shared links open a place there (hash routes).
  static const String webAppUrl = 'https://dangkhanhaa.github.io/rivertide/';

  /// Android app file published next to the web app (sideload, no store).
  static const String apkUrl = '${webAppUrl}con-nuoc.apk';

  /// Supabase project for community spots (P2-19). The anon key is public by
  /// design (access is limited by RLS); the service_role key never ships.
  /// Empty: the community feature stays hidden.
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get communityEnabled =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;
}
