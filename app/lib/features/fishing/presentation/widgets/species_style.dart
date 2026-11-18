import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/fishing/no_bite.dart';
import 'package:rivertide/core/calc/fishing/species_guide.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/l10n/gen/app_localizations.dart';

/// Texts of one species in the handbook.
typedef SpeciesTexts = ({String name, String where, String bait, String chum, String how});

extension SpeciesStyle on BuildContext {
  SpeciesTexts species(FishSpecies s) => _texts(l10n, s);

  /// "06:00–07:00", or "Mai 06:00–07:00" when it starts on the next local
  /// day; "Chưa có giờ hợp" without a window.
  String speciesSpan(SpeciesOutlook o, DateTime nowUtc) {
    final start = o.bestStartUtc;
    final end = o.bestEndUtc;
    if (start == null || end == null) return l10n.sp_noTime;
    final span = '${TimeFormat.hm(start)}–${TimeFormat.hm(end)}';
    final tomorrow = TimeFormat.vnDayStartUtc(start).isAfter(TimeFormat.vnDayStartUtc(nowUtc));
    return tomorrow ? '${l10n.common_tomorrow} $span' : span;
  }

  String habitatName(Habitat h) => switch (h) {
    Habitat.pond => l10n.habitat_pond,
    Habitat.river => l10n.habitat_river,
    Habitat.estuary => l10n.habitat_estuary,
    Habitat.sea => l10n.habitat_sea,
  };

  String depthName(WaterDepth d) => switch (d) {
    WaterDepth.surface => l10n.depth_surface,
    WaterDepth.middle => l10n.depth_middle,
    WaterDepth.bottom => l10n.depth_bottom,
  };

  /// Colour of the species' main water: ponds teal, rivers blue, estuary
  /// green, sea deep blue — the same colours as on the map.
  Color speciesColor(FishSpecies s) => switch (s.habitats.first) {
    Habitat.pond => colors.pond,
    Habitat.river => colors.water,
    Habitat.estuary => colors.fishGood,
    Habitat.sea => colors.primary,
  };

  String speciesTip(SpeciesTip t) => switch (t) {
    SpeciesTip.outOfSeason => l10n.spTip_outOfSeason,
    SpeciesTip.waitForCurrent => l10n.spTip_waitForCurrent,
    SpeciesTip.murkyStrongBait => l10n.spTip_murkyStrongBait,
    SpeciesTip.coldSmallBaitDeep => l10n.spTip_coldSmallBaitDeep,
    SpeciesTip.hotGoDeepShade => l10n.spTip_hotGoDeepShade,
    SpeciesTip.pressureFallingBite => l10n.spTip_pressureFallingBite,
    SpeciesTip.pressureRisingFinesse => l10n.spTip_pressureRisingFinesse,
    SpeciesTip.windDownwind => l10n.spTip_windDownwind,
    SpeciesTip.risingNearBank => l10n.spTip_risingNearBank,
    SpeciesTip.fallingDeeper => l10n.spTip_fallingDeeper,
  };

  (IconData, String) noBite(NoBiteTip t) {
    final at = switch (t.atUtc) {
      final a? => TimeFormat.hm(a),
      null => '',
    };
    return switch (t.kind) {
      NoBiteKind.waitCurrent => (Icons.hourglass_bottom_rounded, l10n.nb_waitCurrent(at)),
      NoBiteKind.goDeepShade => (Icons.wb_sunny_rounded, l10n.nb_goDeepShade),
      NoBiteKind.coldSlow => (Icons.ac_unit_rounded, l10n.nb_coldSlow),
      NoBiteKind.murkySmell => (Icons.water_drop_rounded, l10n.nb_murkySmell),
      NoBiteKind.finesse => (Icons.tune_rounded, l10n.nb_finesse),
      NoBiteKind.downwind => (Icons.air_rounded, l10n.nb_downwind),
      NoBiteKind.nextGolden => (Icons.star_rounded, l10n.nb_nextGolden(at)),
      NoBiteKind.changeDepth => (Icons.height_rounded, l10n.nb_changeDepth),
      NoBiteKind.moveSpot => (Icons.directions_walk_rounded, l10n.nb_moveSpot),
      NoBiteKind.freshBait => (Icons.restaurant_rounded, l10n.nb_freshBait),
      NoBiteKind.stayQuiet => (Icons.volume_off_rounded, l10n.nb_stayQuiet),
      NoBiteKind.finerLine => (Icons.linear_scale_rounded, l10n.nb_finerLine),
    };
  }
}

SpeciesTexts _texts(AppLocalizations l, FishSpecies s) => switch (s) {
  FishSpecies.carp => (
    name: l.sp_carp,
    where: l.sp_carp_where,
    bait: l.sp_carp_bait,
    chum: l.sp_carp_chum,
    how: l.sp_carp_how,
  ),
  FishSpecies.tilapia => (
    name: l.sp_tilapia,
    where: l.sp_tilapia_where,
    bait: l.sp_tilapia_bait,
    chum: l.sp_tilapia_chum,
    how: l.sp_tilapia_how,
  ),
  FishSpecies.grassCarp => (
    name: l.sp_grassCarp,
    where: l.sp_grassCarp_where,
    bait: l.sp_grassCarp_bait,
    chum: l.sp_grassCarp_chum,
    how: l.sp_grassCarp_how,
  ),
  FishSpecies.snakehead => (
    name: l.sp_snakehead,
    where: l.sp_snakehead_where,
    bait: l.sp_snakehead_bait,
    chum: l.sp_snakehead_chum,
    how: l.sp_snakehead_how,
  ),
  FishSpecies.walkingCatfish => (
    name: l.sp_walkingCatfish,
    where: l.sp_walkingCatfish_where,
    bait: l.sp_walkingCatfish_bait,
    chum: l.sp_walkingCatfish_chum,
    how: l.sp_walkingCatfish_how,
  ),
  FishSpecies.pangasius => (
    name: l.sp_pangasius,
    where: l.sp_pangasius_where,
    bait: l.sp_pangasius_bait,
    chum: l.sp_pangasius_chum,
    how: l.sp_pangasius_how,
  ),
  FishSpecies.mystus => (
    name: l.sp_mystus,
    where: l.sp_mystus_where,
    bait: l.sp_mystus_bait,
    chum: l.sp_mystus_chum,
    how: l.sp_mystus_how,
  ),
  FishSpecies.mullet => (
    name: l.sp_mullet,
    where: l.sp_mullet_where,
    bait: l.sp_mullet_bait,
    chum: l.sp_mullet_chum,
    how: l.sp_mullet_how,
  ),
  FishSpecies.seabass => (
    name: l.sp_seabass,
    where: l.sp_seabass_where,
    bait: l.sp_seabass_bait,
    chum: l.sp_seabass_chum,
    how: l.sp_seabass_how,
  ),
  FishSpecies.snapper => (
    name: l.sp_snapper,
    where: l.sp_snapper_where,
    bait: l.sp_snapper_bait,
    chum: l.sp_snapper_chum,
    how: l.sp_snapper_how,
  ),
  FishSpecies.grouper => (
    name: l.sp_grouper,
    where: l.sp_grouper_where,
    bait: l.sp_grouper_bait,
    chum: l.sp_grouper_chum,
    how: l.sp_grouper_how,
  ),
  FishSpecies.goby => (
    name: l.sp_goby,
    where: l.sp_goby_where,
    bait: l.sp_goby_bait,
    chum: l.sp_goby_chum,
    how: l.sp_goby_how,
  ),
  FishSpecies.climbingPerch => (
    name: l.sp_climbingPerch,
    where: l.sp_climbingPerch_where,
    bait: l.sp_climbingPerch_bait,
    chum: l.sp_climbingPerch_chum,
    how: l.sp_climbingPerch_how,
  ),
  FishSpecies.crucian => (
    name: l.sp_crucian,
    where: l.sp_crucian_where,
    bait: l.sp_crucian_bait,
    chum: l.sp_crucian_chum,
    how: l.sp_crucian_how,
  ),
  FishSpecies.bighead => (
    name: l.sp_bighead,
    where: l.sp_bighead_where,
    bait: l.sp_bighead_bait,
    chum: l.sp_bighead_chum,
    how: l.sp_bighead_how,
  ),
};
