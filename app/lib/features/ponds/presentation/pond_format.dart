import 'package:flutter/widgets.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';

/// How anglers say weights: "300 kg", "7 tạ", "1,5 tấn".
String pondAmount(BuildContext context, int kg) {
  final l = context.l10n;
  if (kg >= 1000) return l.pond_ton(_trim(LevelFormat.decimal1(kg / 1000)));
  if (kg >= 100 && kg % 10 == 0) return l.pond_ta(_trim(LevelFormat.decimal1(kg / 100)));
  return l.pond_kg('$kg');
}

String _trim(String s) => s.endsWith(',0') ? s.substring(0, s.length - 2) : s;

/// "T7, 15/11 · 6:00".
String pondWhen(DateTime utc) => '${TimeFormat.dayShort(utc)} · ${TimeFormat.hm(utc)}';

/// "Chép 5 tạ, Trắm 2 tạ, Lăng".
String pondFish(BuildContext context, PondRelease r) => r.fish
    .map((f) => f.kg == null ? f.species : '${f.species} ${pondAmount(context, f.kg ?? 0)}')
    .join(', ');
