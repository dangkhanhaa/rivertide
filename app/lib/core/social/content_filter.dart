import 'package:rivertide/core/format/text_fold.dart';

/// Instant feedback before sending community text (P2-54). Mirrors the server
/// filter in supabase/migrations/0005_anti_spam.sql (`content_issue`); the
/// server stays the authority (its word list is editable and longer).

/// What a text field is for. Mirrors the server kinds.
enum ContentKind {
  /// Comments, chat, notes, reviews: every rule.
  text,

  /// Titles, place names, prices: every rule but all-caps.
  title,

  /// Display names: [title] rules + names pretending to be the app's team.
  name,

  /// A pond's pasted announcement: no links or bad words; its phone stays.
  post,

  /// Phone / Zalo / link fields: only bad words and gambling spam.
  contact,
}

/// Why a text is refused; [fromServer] maps the server's reason code.
enum ContentIssue {
  link,
  phone,
  contactAd,
  spam,
  offensive,
  chars,
  shouting,
  impersonation,
  repeat,
  other;

  static ContentIssue fromServer(String code) => switch (code) {
    'link' => link,
    'phone' => phone,
    'contact_ad' => contactAd,
    'spam' => spam,
    'offensive' => offensive,
    'chars' => chars,
    'shouting' => shouting,
    'impersonation' => impersonation,
    'repeat' => repeat,
    _ => other,
  };
}

// Without accents they would hit everyday words ("lồn"/"lớn", "cặc"/"các").
const _offensiveAccented = [
  'địt', 'đụ', 'lồn', 'cặc', 'buồi', 'đéo', 'đĩ', 'đm', 'đmm', 'đcm', //
  'óc chó', 'chó đẻ', 'thằng chó', 'đồ chó', 'thằng ngu', 'đồ ngu', 'súc sinh',
];
const _offensiveFolded = [
  'dcm',
  'dmm',
  'dkm',
  'vcl',
  'vkl',
  'clgt',
  'loz',
  'djt',
  'dit me',
  'fuck',
  'shit',
  'bitch', //
];
const _spamFolded = [
  'nha cai',
  'casino',
  'tai xiu',
  'doi thuong',
  'kiem tien online',
  'vay tien',
  'baccarat', //
  'game bai', 'sex',
];
const _spamAccented = ['cá độ', 'nổ hũ', 'lô đề', 'gái gọi'];
const _contactAdFolded = [
  'zalo',
  'zl',
  'telegram',
  'viber',
  'whatsapp',
  'wechat',
  'inbox',
  'ib',
  'sdt',
  'hotline', //
  'ket ban',
];
const _impersonationParts = ['admin', 'quantri', 'connuoc', 'moderator', 'rivertide', 'kiemduyet'];
const _impersonationWords = ['mod', 'ho tro', 'support', 'cskh'];

final _nonWord = RegExp(r'[^\p{L}\p{N}]+', unicode: true);
final _nonWordAscii = RegExp('[^a-z0-9]+');
final _links = [
  RegExp(r'h\s*t\s*t\s*p\s*s?\s*:\s*/\s*/'),
  RegExp(r'(^|[^a-z0-9])www\s*[.,]'),
  RegExp(
    r'[a-z0-9-]{2,}\.(com|net|org|info|biz|xyz|vn|io|site|online|store|club|link|click|live'
    r'|shop|app|tv|asia|pro|fun|vip|bet|win)([^a-z0-9]|$)',
  ),
  RegExp(r'(^|[^a-z0-9])(t|m)\.me/'),
  RegExp(r'(bit\.ly|goo\.gl|tinyurl|cutt\.ly|shorturl)'),
  RegExp(r'(dot|chấm|cham)\s*(com|net|org|vn)([^a-z0-9]|$)'),
  RegExp(r'[(\[]\s*(\.|dot|chấm|cham)\s*[)\]]'),
];
final _phone = RegExp(r'(^|[^0-9])(\+\s?84|84|0)[\s.\-]?[1-9]([\s.\-]?[0-9]){8,9}([^0-9]|$)');
final _repeated = RegExp(r'([a-z])\1{4,}');

String _pad(String words) => ' ${words.trim()} ';

bool _hasWord(String padded, String term) => padded.contains(' $term ');

/// Null when [input] looks fine for a field of [kind].
ContentIssue? contentIssue(String input, ContentKind kind) {
  final lower = input.toLowerCase();
  final folded = TextFold.fold(input);
  final fw = _pad(folded.replaceAll(_nonWordAscii, ' '));
  final aw = _pad(lower.replaceAll(_nonWord, ' '));
  if (fw.trim().isEmpty) return null;
  final public = kind != ContentKind.post && kind != ContentKind.contact;
  if (kind != ContentKind.contact && _links.any((r) => r.hasMatch(lower))) return ContentIssue.link;
  if (public && _phone.hasMatch(folded)) return ContentIssue.phone;
  if (_offensiveAccented.any((t) => _hasWord(aw, t)) ||
      _offensiveFolded.any((t) => _hasWord(fw, t))) {
    return ContentIssue.offensive;
  }
  if (_spamFolded.any((t) => _hasWord(fw, t)) || _spamAccented.any((t) => _hasWord(aw, t))) {
    return ContentIssue.spam;
  }
  if (public && _contactAdFolded.any((t) => _hasWord(fw, t))) return ContentIssue.contactAd;
  if (kind == ContentKind.name) {
    final compact = fw.replaceAll(' ', '');
    if (_impersonationParts.any(compact.contains) ||
        _impersonationWords.any((t) => _hasWord(fw, t))) {
      return ContentIssue.impersonation;
    }
  }
  if (public && _repeated.hasMatch(folded)) return ContentIssue.chars;
  if (kind == ContentKind.text && _isShouting(input)) return ContentIssue.shouting;
  return null;
}

/// The first issue among several fields, each with its kind.
ContentIssue? firstContentIssue(List<(String, ContentKind)> fields) {
  for (final (text, kind) in fields) {
    final issue = contentIssue(text, kind);
    if (issue != null) return issue;
  }
  return null;
}

// ≥ 24 letters and ≥ 90 % capitals (accented capitals count too).
bool _isShouting(String input) {
  var up = 0;
  var low = 0;
  for (final ch in input.split('')) {
    final u = ch.toUpperCase();
    final l = ch.toLowerCase();
    if (u == l) continue;
    if (ch == u) {
      up++;
    } else {
      low++;
    }
  }
  return up + low >= 24 && up >= 0.9 * (up + low);
}
