import 'package:rivertide/core/format/text_fold.dart';

/// Checks for the public display name (P2-53). The server's `clean_name`
/// only strips control characters and cuts to 30; these rules stop the
/// mistakes and tricks people otherwise only notice once the name is public.
enum NameIssue { tooShort, tooLong, badChars, link, phone, reserved }

const int displayNameMinChars = 2;
const int displayNameMaxChars = 30;

/// Control, zero-width and text-direction characters: invisible, so they can
/// make two names look the same.
final RegExp _hidden = RegExp(
  r'[\u0000-\u001F\u007F-\u009F\u200B-\u200F\u202A-\u202E\u2060-\u2064\uFEFF]',
);

final RegExp _link = RegExp(
  r'(https?:|www\.|[a-z0-9-]\.(com|net|org|vn|io|me|xyz|info|link|app|site)\b|@[a-z0-9_]{3,})',
  caseSensitive: false,
);

/// Words reserved for the team or the app (accent-insensitive, whole words).
final RegExp _reserved = RegExp(
  r'\b(admin|administrator|mod|moderator|quan tri|quantri|ban quan tri|quan tri vien|'
  'con nuoc|connuoc|rivertide|river tide|ho tro|hotro|support|official|chinh thuc|'
  r'he thong|system|nha phat trien|developer)\b',
);

/// Trimmed name with inner spaces collapsed: what gets saved.
String normalizeDisplayName(String raw) => raw.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Null when [raw] is fine. An empty name is fine (anonymous).
NameIssue? checkDisplayName(String raw) {
  final name = normalizeDisplayName(raw);
  if (name.isEmpty) return null;
  if (_hidden.hasMatch(name)) return NameIssue.badChars;
  final chars = name.runes.length;
  if (chars < displayNameMinChars) return NameIssue.tooShort;
  if (chars > displayNameMaxChars) return NameIssue.tooLong;
  if (_link.hasMatch(name)) return NameIssue.link;
  if (RegExp(r'\d').allMatches(name).length >= 7) return NameIssue.phone;
  if (_reserved.hasMatch(TextFold.fold(name))) return NameIssue.reserved;
  return null;
}
