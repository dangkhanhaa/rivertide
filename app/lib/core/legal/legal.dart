import 'package:rivertide/core/config/env.dart';
import 'package:url_launcher/url_launcher.dart';

/// Terms of use / privacy policy (P2-57). Bump [termsVersion] when the
/// texts change in a way users must agree to again: everyone then sees the
/// acceptance screen once more (before any screen, links included).
const int termsVersion = 1;

/// Full texts, served with the web app on GitHub Pages (app/web/*.html).
const String termsUrl = '${Env.webAppUrl}terms.html';
const String privacyUrl = '${Env.webAppUrl}privacy.html';

/// Where people report content, ask about their data or contact the owner.
const String contactUrl = 'https://github.com/dangkhanhaa/rivertide/issues';

/// Opens one of the fixed links above outside the app (browser tab on web).
Future<bool> openLegalLink(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
