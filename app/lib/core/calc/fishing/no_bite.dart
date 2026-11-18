import 'package:rivertide/core/calc/fishing/spot_conditions.dart';

/// "Cá không ăn? Thử…" (P2-32): what to try, situation-specific first, then
/// the classic checks every angler runs through. Common angling practice,
/// shown as suggestions.
enum NoBiteKind {
  /// Slack water: wait for the current (`atUtc` = next turn + ~30 min).
  waitCurrent,

  /// Bright midday: fish go deep or into shade.
  goDeepShade,

  /// Cold snap: smaller bait, slower, deeper.
  coldSlow,

  /// Murky after rain: strong-smelling bait, fish clearer edges.
  murkySmell,

  /// Pressure rising after a front: finer line, smaller hook.
  finesse,

  /// Wind: move to the bank the wind blows towards.
  downwind,

  /// Next golden window (`atUtc` = its start).
  nextGolden,
  changeDepth,
  moveSpot,
  freshBait,
  stayQuiet,
  finerLine,
}

typedef NoBiteTip = ({NoBiteKind kind, DateTime? atUtc});

/// Golden-hour threshold, same as the fishing tab.
const double _golden = 7;

List<NoBiteTip> noBiteTips(SpotConditions c) {
  final out = <NoBiteTip>[];
  final turn = c.nextTurnUtc;
  if (c.isSlack && turn != null) {
    // Water starts running a little after the turn.
    out.add((kind: NoBiteKind.waitCurrent, atUtc: turn.add(const Duration(minutes: 30))));
  }
  if (c.hot || c.harshSun) out.add((kind: NoBiteKind.goDeepShade, atUtc: null));
  if (c.coldSnap) out.add((kind: NoBiteKind.coldSlow, atUtc: null));
  if (c.murky) out.add((kind: NoBiteKind.murkySmell, atUtc: null));
  if (c.pressureRising) out.add((kind: NoBiteKind.finesse, atUtc: null));
  if (c.windy) out.add((kind: NoBiteKind.downwind, atUtc: null));
  final now = c.ahead.isEmpty ? null : c.ahead.first;
  final next = c.ahead.skip(1).where((h) => h.score >= _golden).firstOrNull;
  if (now != null && now.score < _golden && next != null) {
    out.add((kind: NoBiteKind.nextGolden, atUtc: next.hourUtc));
  }
  return [
    ...out,
    for (final k in [
      NoBiteKind.changeDepth,
      NoBiteKind.moveSpot,
      NoBiteKind.freshBait,
      NoBiteKind.stayQuiet,
      if (!c.pressureRising) NoBiteKind.finerLine,
    ])
      (kind: k, atUtc: null),
  ];
}
