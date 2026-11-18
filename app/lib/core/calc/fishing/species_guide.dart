import 'package:rivertide/core/calc/fishing/spot_conditions.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';

/// Species handbook (P2-32): habits of common Vietnamese catches and how
/// today's real conditions change the advice. Habits are common angling
/// knowledge, shown as reference; the texts live in app_vi.arb.

enum Habitat { pond, river, estuary, sea }

enum WaterDepth { surface, middle, bottom }

/// Preferred water temperature band.
enum TempLike { warm, cool }

enum FishSpecies {
  carp(
    habitats: {Habitat.pond, Habitat.river},
    peakMonths: {3, 4, 5, 9, 10, 11},
    feeds: {DayPart.dawn, DayPart.dusk},
    depth: WaterDepth.bottom,
  ),
  tilapia(
    habitats: {Habitat.pond, Habitat.river},
    peakMonths: {4, 5, 6, 7, 8, 9, 10},
    feeds: {DayPart.dawn, DayPart.day, DayPart.dusk},
    depth: WaterDepth.middle,
  ),
  grassCarp(
    habitats: {Habitat.pond, Habitat.river},
    peakMonths: {4, 5, 6, 7, 8, 9, 10},
    feeds: {DayPart.dawn, DayPart.dusk},
    depth: WaterDepth.middle,
  ),
  snakehead(
    habitats: {Habitat.pond, Habitat.river},
    peakMonths: {4, 5, 6, 7, 8, 9},
    feeds: {DayPart.dawn, DayPart.dusk},
    depth: WaterDepth.surface,
  ),
  walkingCatfish(
    habitats: {Habitat.pond, Habitat.river},
    peakMonths: {4, 5, 6, 7, 8, 9, 10},
    feeds: {DayPart.night, DayPart.dusk},
    depth: WaterDepth.bottom,
  ),
  pangasius(
    habitats: {Habitat.river, Habitat.pond},
    peakMonths: {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
    feeds: {DayPart.dusk, DayPart.night},
    depth: WaterDepth.middle,
  ),
  mystus(
    habitats: {Habitat.river},
    peakMonths: {9, 10, 11, 12, 1, 2, 3},
    feeds: {DayPart.dusk, DayPart.night},
    depth: WaterDepth.bottom,
    tempLike: TempLike.cool,
    needsCurrent: true,
  ),
  mullet(
    habitats: {Habitat.estuary, Habitat.sea},
    peakMonths: {12, 1, 2, 3, 4, 5},
    feeds: {DayPart.dawn, DayPart.day, DayPart.dusk},
    depth: WaterDepth.middle,
    needsCurrent: true,
  ),
  seabass(
    habitats: {Habitat.estuary, Habitat.sea},
    peakMonths: {5, 6, 7, 8, 9, 10, 11},
    feeds: {DayPart.dawn, DayPart.dusk},
    depth: WaterDepth.middle,
    needsCurrent: true,
  ),
  snapper(
    habitats: {Habitat.sea},
    peakMonths: {3, 4, 5, 6, 7, 8, 9},
    feeds: {DayPart.dawn, DayPart.night},
    depth: WaterDepth.bottom,
    needsCurrent: true,
  ),
  grouper(
    habitats: {Habitat.sea},
    peakMonths: {4, 5, 6, 7, 8, 9, 10},
    feeds: {DayPart.dawn, DayPart.day},
    depth: WaterDepth.bottom,
    needsCurrent: true,
  ),
  goby(
    habitats: {Habitat.estuary, Habitat.river},
    peakMonths: {6, 7, 8, 9, 10, 11, 12},
    feeds: {DayPart.dusk, DayPart.night},
    depth: WaterDepth.bottom,
  ),
  climbingPerch(
    habitats: {Habitat.pond},
    peakMonths: {4, 5, 6, 7, 8, 9, 10},
    feeds: {DayPart.dawn, DayPart.dusk},
    depth: WaterDepth.surface,
  ),
  crucian(
    habitats: {Habitat.pond},
    peakMonths: {10, 11, 12, 1, 2, 3, 4},
    feeds: {DayPart.dawn, DayPart.day},
    depth: WaterDepth.bottom,
    tempLike: TempLike.cool,
  ),
  bighead(
    habitats: {Habitat.pond, Habitat.river},
    peakMonths: {4, 5, 6, 7, 8, 9, 10},
    feeds: {DayPart.day},
    depth: WaterDepth.surface,
  );

  FishSpecies({
    required this.habitats,
    required this.peakMonths,
    required this.feeds,
    required this.depth,
    this.tempLike = TempLike.warm,
    this.needsCurrent = false,
  });

  final Set<Habitat> habitats;

  /// Months (1–12) of the main season; fish bite outside it too, less.
  final Set<int> peakMonths;
  final Set<DayPart> feeds;
  final WaterDepth depth;
  final TempLike tempLike;

  /// Feeds mostly while the water runs (estuary/sea/river current fish).
  final bool needsCurrent;
}

/// Why today is better or worse for a species, most useful first.
enum SpeciesTip {
  outOfSeason,
  waitForCurrent,
  murkyStrongBait,
  coldSmallBaitDeep,
  hotGoDeepShade,
  pressureFallingBite,
  pressureRisingFinesse,
  windDownwind,
  risingNearBank,
  fallingDeeper,
}

class SpeciesOutlook {
  const SpeciesOutlook({
    required this.species,
    required this.score,
    required this.inSeason,
    required this.tips,
    this.bestStartUtc,
    this.bestEndUtc,
  });

  final FishSpecies species;

  /// 0–10 estimate for the best suitable window in the next 24 h.
  final double score;
  final bool inSeason;
  final List<SpeciesTip> tips;
  final DateTime? bestStartUtc;
  final DateTime? bestEndUtc;
}

/// [month] is the local month (1–12).
SpeciesOutlook speciesOutlook(FishSpecies s, SpotConditions c, int month) {
  final inSeason = s.peakMonths.contains(month);
  final window = _bestWindow(s, c.ahead);
  final factor = (inSeason ? 1.0 : 0.8) * _tempFit(s, c.tempC);
  final score = window == null ? 0.0 : (window.score * factor * 10).round() / 10;
  return SpeciesOutlook(
    species: s,
    score: score.clamp(0, 10).toDouble(),
    inSeason: inSeason,
    tips: _tips(s, c, inSeason),
    bestStartUtc: window?.start,
    bestEndUtc: window?.end,
  );
}

/// All species, best today first.
List<SpeciesOutlook> rankSpecies(SpotConditions c, int month) =>
    [for (final s in FishSpecies.values) speciesOutlook(s, c, month)]
      ..sort((a, b) => b.score.compareTo(a.score));

double _tempFit(FishSpecies s, double? t) {
  if (t == null) return 1;
  if (s.tempLike == TempLike.cool) return t > 32 ? 0.75 : (t < 12 ? 0.7 : 1);
  if (t < 16) return 0.6;
  if (t < 20) return 0.8;
  if (t > 34) return 0.85;
  return 1;
}

/// Best run of hours in the species' feeding parts of the day: the peak hour
/// and its neighbours within 1 point of it.
({DateTime start, DateTime end, double score})? _bestWindow(FishSpecies s, List<ScoredHour> ahead) {
  final fit = [
    for (final (i, h) in ahead.indexed)
      if (s.feeds.contains(h.part)) i,
  ];
  if (fit.isEmpty) return null;
  final peak = fit.reduce((a, b) => ahead[b].score > ahead[a].score ? b : a);
  final top = ahead[peak].score;
  bool ok(int i) => fit.contains(i) && ahead[i].score >= top - 1;
  var from = peak;
  var to = peak;
  while (from > 0 && ok(from - 1)) {
    from--;
  }
  while (to < ahead.length - 1 && ok(to + 1)) {
    to++;
  }
  return (
    start: ahead[from].hourUtc,
    end: ahead[to].hourUtc.add(const Duration(hours: 1)),
    score: top,
  );
}

List<SpeciesTip> _tips(FishSpecies s, SpotConditions c, bool inSeason) => [
  if (!inSeason) SpeciesTip.outOfSeason,
  if (s.needsCurrent && c.isSlack) SpeciesTip.waitForCurrent,
  if (c.murky) SpeciesTip.murkyStrongBait,
  if (c.coldSnap && s.tempLike == TempLike.warm) SpeciesTip.coldSmallBaitDeep,
  if (c.hot) SpeciesTip.hotGoDeepShade,
  if (c.pressureFalling) SpeciesTip.pressureFallingBite,
  if (c.pressureRising) SpeciesTip.pressureRisingFinesse,
  if (c.windy) SpeciesTip.windDownwind,
  if (c.tide case final t? when !c.isSlack && s.depth != WaterDepth.surface)
    if (isRising(t)) SpeciesTip.risingNearBank else SpeciesTip.fallingDeeper,
];
