import 'package:rivertide/core/format/text_fold.dart';

/// Reads a pond owner's post ("Mai xả 5 tạ chép, 2 tạ trắm, mở cổng 6h") into
/// a release ("xả cá") draft: day, time, fish and weights. Rule based, offline,
/// Vietnamese only. The owner always confirms the draft before it is published.

/// One species and how much of it (null = not said).
typedef ReleaseFish = ({String species, int? kg});

class ReleaseDraft {
  const ReleaseDraft({
    required this.isRelease,
    required this.fish,
    this.dayLocal,
    this.hour,
    this.minute = 0,
  });

  /// The text talks about releasing / restocking fish.
  final bool isRelease;

  /// Vietnam calendar day (time part 00:00), null when no day was found.
  final DateTime? dayLocal;
  final int? hour;
  final int minute;
  final List<ReleaseFish> fish;

  int? get totalKg {
    final known = fish.map((f) => f.kg).nonNulls;
    return known.isEmpty ? null : known.fold<int>(0, (a, b) => a + b);
  }

  /// Start in UTC (Vietnam = UTC+7); hour defaults to 6:00 when unknown.
  DateTime? get startUtc {
    final d = dayLocal;
    if (d == null) return null;
    return DateTime.utc(d.year, d.month, d.day, hour ?? 6, minute).subtract(_vn);
  }

  /// Enough to publish: a day plus either fish or the release words.
  bool get usable => isRelease && dayLocal != null;
}

const Duration _vn = Duration(hours: 7);

/// Folded (no accents) species name → display name. Longer keys first.
const List<(String, String)> releaseSpecies = [
  ('dieu hong', 'Diêu hồng'),
  ('ro phi', 'Rô phi'),
  ('ro dong', 'Rô đồng'),
  ('tram den', 'Trắm đen'),
  ('tram co', 'Trắm cỏ'),
  ('chim trang', 'Chim trắng'),
  ('hong my', 'Hồng mỹ'),
  ('ca qua', 'Cá lóc'),
  ('ca loc', 'Cá lóc'),
  ('ca tam', 'Cá tầm'),
  ('ba sa', 'Ba sa'),
  ('basa', 'Ba sa'),
  ('chep', 'Chép'),
  ('tram', 'Trắm'),
  ('lang', 'Lăng'),
  ('chim', 'Chim'),
  ('tre', 'Trê'),
  ('tra', 'Tra'),
  ('me', 'Mè'),
  ('chem', 'Chẽm'),
  ('bong', 'Bống'),
  ('loc', 'Cá lóc'),
  ('qua', 'Cá lóc'),
];

/// Species keys that are also everyday words: they count without "cá" only
/// inside a release post ([_riskyWords] never do: "kiểm tra", "qua đây").
const Set<String> _plainWords = {'me', 'tre', 'chim', 'lang', 'tram'};
const Set<String> _riskyWords = {'tra', 'bong', 'loc', 'qua'};

/// "xả / thả / đổ / bổ sung / về" + "cá" / "hàng" / an amount / a species name.
final RegExp _releaseWords = RegExp(
  r'\b(xa|tha|do|bo sung|ve)\s+(them\s+)?(ca|hang|\d+|'
  '${releaseSpecies.map((s) => s.$1).join('|')})'
  r'\b|\bca ve\b',
);

/// Units in kg; "ký"/"cân" are spoken forms of kg.
const Map<String, int> _units = {'tan': 1000, 'ta': 100, 'yen': 10, 'kg': 1, 'ky': 1, 'can': 1};

ReleaseDraft parseRelease(String text, DateTime nowUtc) {
  final t = TextFold.fold(text).replaceAll(RegExp('[!?.;\n]+'), ' , ');
  final today = _vnDay(nowUtc);
  final release = _releaseWords.hasMatch(t);
  final time = _time(t);
  return ReleaseDraft(
    isRelease: release,
    dayLocal: _day(t, today),
    hour: time?.$1,
    minute: time?.$2 ?? 0,
    fish: _fish(t, inRelease: release),
  );
}

DateTime _vnDay(DateTime utc) {
  final l = utc.add(_vn);
  return DateTime(l.year, l.month, l.day);
}

DateTime? _day(String t, DateTime today) {
  // Explicit date first: "15/11", "15-11", "ngay 15 thang 11".
  final m =
      RegExp(r'\b(\d{1,2})\s*[/-]\s*(\d{1,2})\b').firstMatch(t) ??
      RegExp(r'\bngay\s+(\d{1,2})\s+thang\s+(\d{1,2})\b').firstMatch(t);
  if (m != null) {
    final d = int.parse(m.group(1) ?? '0');
    final mo = int.parse(m.group(2) ?? '0');
    if (d >= 1 && d <= 31 && mo >= 1 && mo <= 12) {
      var date = DateTime(today.year, mo, d);
      // A date well in the past means next year ("02/01" written in December).
      if (date.isBefore(today.subtract(const Duration(days: 7)))) {
        date = DateTime(today.year + 1, mo, d);
      }
      return date;
    }
  }
  if (RegExp(r'\b(ngay kia|ngay mot|mot)\b').hasMatch(t)) return today.add(const Duration(days: 2));
  if (RegExp(r'\b(ngay mai|sang mai|chieu mai|toi mai|mai)\b').hasMatch(t)) {
    return today.add(const Duration(days: 1));
  }
  if (RegExp(r'\b(hom nay|sang nay|chieu nay|toi nay)\b').hasMatch(t)) return today;
  final wd = _weekday(t);
  if (wd != null) return today.add(Duration(days: (wd - today.weekday + 7) % 7));
  return null;
}

/// DateTime.weekday (Mon = 1 … Sun = 7) from "thứ 7", "t7", "thứ bảy", "cn".
int? _weekday(String t) {
  const words = {'hai': 1, 'ba': 2, 'tu': 3, 'nam': 4, 'sau': 5, 'bay': 6};
  final n = RegExp(r'\b(?:thu|t)\s*([2-7])\b').firstMatch(t);
  if (n != null) return int.parse(n.group(1) ?? '2') - 1;
  final w = RegExp(r'\bthu\s+(hai|ba|tu|nam|sau|bay)\b').firstMatch(t);
  if (w != null) return words[w.group(1)];
  if (RegExp(r'\b(cn|chu nhat)\b').hasMatch(t)) return 7;
  return null;
}

/// (hour, minute) from "6h", "6h30", "6:30", "6 gio", "6g"; "chieu/toi" → PM.
(int, int)? _time(String t) {
  final m = RegExp(r'\b(\d{1,2})\s*(?:h|g|gio|:)\s*(\d{2})?\b(?:\s*(sang|trua|chieu|toi))?')
      .firstMatch(t);
  if (m == null) return null;
  var h = int.parse(m.group(1) ?? '0');
  final min = int.tryParse(m.group(2) ?? '') ?? 0;
  final part = m.group(3) ?? RegExp(r'\b(chieu|toi)\b').firstMatch(t)?.group(1);
  if ((part == 'chieu' || part == 'toi') && h < 12) h += 12;
  if (h > 23 || min > 59) return null;
  return (h, min);
}

/// "5 ta chep", "chep 5 ta", "1,5 tan tram", "300kg ro phi".
List<ReleaseFish> _fish(String t, {required bool inRelease}) {
  final out = <String, int?>{};
  final amount = RegExp(r'(\d+(?:[.,]\d+)?)\s*(tan|ta|yen|kg|ky|can)\b');
  for (final m in amount.allMatches(t)) {
    final kg = (double.parse((m.group(1) ?? '0').replaceAll(',', '.')) * (_units[m.group(2)] ?? 1))
        .round();
    final after = _speciesAt(t, m.end);
    final before = _speciesBefore(t, m.start);
    final name = after ?? before;
    if (name != null) out[name] = (out[name] ?? 0) + kg;
  }
  // Species named without an amount ("xả chép, trắm"). Keys are tried longest
  // first and blanked once used, so "trắm đen" does not also count as "trắm".
  // Short names that are everyday words ("kiểm tra") count only after "cá".
  var rest = t;
  for (final (key, name) in releaseSpecies) {
    final strict = _riskyWords.contains(key) || (!inRelease && _plainWords.contains(key));
    final re = RegExp(strict ? '\\bca $key\\b' : '\\b$key\\b');
    if (!re.hasMatch(rest)) continue;
    rest = rest.replaceAll(re, ' ');
    out.putIfAbsent(name, () => null);
  }
  return [for (final e in out.entries) (species: e.key, kg: e.value)];
}

String? _speciesAt(String t, int from) {
  final rest = t.substring(from).replaceFirst(RegExp(r'^\s*(ca\s+)?'), '');
  for (final (key, name) in releaseSpecies) {
    if (RegExp('^$key\\b').hasMatch(rest)) return name;
  }
  return null;
}

String? _speciesBefore(String t, int end) {
  final head = t.substring(0, end).trimRight();
  for (final (key, name) in releaseSpecies) {
    if (RegExp('\\b$key\\s*:?\$').hasMatch(head)) return name;
  }
  return null;
}
