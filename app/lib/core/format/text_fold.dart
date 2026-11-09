/// Accent-insensitive search for Vietnamese ("can tho" matches "Cần Thơ", FEATURES.md F-MAP-04).
abstract final class TextFold {
  static const _groups = <String, String>{
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };

  static final Map<int, String> _map = {
    for (final e in _groups.entries)
      for (final r in e.value.runes) r: e.key,
  };

  /// Lower-case, strips Vietnamese diacritics and collapses whitespace.
  static String fold(String input) {
    final buf = StringBuffer();
    for (final r in input.toLowerCase().runes) {
      buf.write(_map[r] ?? String.fromCharCode(r));
    }
    return buf.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// True when every word of [query] appears in [text] (both folded).
  static bool matches(String text, String query) {
    final q = fold(query);
    if (q.isEmpty) return false;
    final t = fold(text);
    return q.split(' ').every(t.contains);
  }
}
