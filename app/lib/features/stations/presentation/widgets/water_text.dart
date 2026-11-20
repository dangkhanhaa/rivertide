import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/geo/tide_verdict.dart';
import 'package:rivertide/core/calc/geo/water_kind.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/features/stations/domain/point_water.dart';

/// Words and icons for water kinds and tide verdicts (P2-50): every colour or
/// icon comes with these words (docs/rules/06 §3).
extension WaterText on BuildContext {
  String waterKindName(WaterKind k) => switch (k) {
    WaterKind.sea => l10n.water_kind_sea,
    WaterKind.river => l10n.water_kind_river,
    WaterKind.canal => l10n.water_kind_canal,
    WaterKind.creek => l10n.water_kind_creek,
    WaterKind.stream => l10n.water_kind_stream,
    WaterKind.ditch => l10n.water_kind_ditch,
    WaterKind.lake => l10n.water_kind_lake,
    WaterKind.pond => l10n.water_kind_pond,
    WaterKind.reservoir => l10n.water_kind_reservoir,
    WaterKind.lagoon => l10n.water_kind_lagoon,
    WaterKind.dock => l10n.water_kind_dock,
    WaterKind.land => l10n.water_kind_land,
    WaterKind.unknown => l10n.water_kind_unknown,
  };

  /// "Sông · Sông Sài Gòn" reads twice: a name that already starts with a
  /// water word is shown alone, others get the kind in front.
  String waterTitle(WaterKind k, String? name) {
    final kind = waterKindName(k);
    if (name == null) return kind;
    final first = name.trim().toLowerCase().split(' ').first;
    return _waterWords.contains(first) ? name : '$kind · $name';
  }

  String tideVerdictText(TideVerdict v) => switch (v) {
    TideVerdict.tidal => l10n.water_tide_tidal,
    TideVerdict.weak => l10n.water_tide_weak,
    TideVerdict.none => l10n.water_tide_none,
    TideVerdict.unknown => l10n.water_tide_unknown,
  };

  String tideReasonText(PointWater w) {
    final km = w.seaKm;
    final far = km == null ? '' : LevelFormat.km(km);
    return switch (w.reason) {
      TideReason.sea => l10n.water_reason_sea,
      TideReason.lagoon => l10n.water_reason_lagoon,
      TideReason.stillWater => l10n.water_reason_still,
      TideReason.land => l10n.water_reason_land,
      TideReason.highGround => l10n.water_reason_highGround((w.elevationM ?? 0).round()),
      TideReason.tidalRiverData => l10n.water_reason_riverData,
      TideReason.southNetwork => l10n.water_reason_southNetwork,
      TideReason.southSmall => l10n.water_reason_southSmall,
      TideReason.northRiver => l10n.water_reason_northRiver,
      TideReason.gated => l10n.water_reason_gated,
      TideReason.nearSea => l10n.water_reason_nearSea(far),
      TideReason.farFromSea => l10n.water_reason_farFromSea(far),
      TideReason.unknownKind => l10n.water_reason_unknownKind,
      TideReason.coastalLake => l10n.water_reason_coastalLake,
      TideReason.noSeaDistance => l10n.water_reason_noSeaDistance,
    };
  }

  String structureName(StructureKind k) => switch (k) {
    StructureKind.dam => l10n.water_structure_dam,
    StructureKind.weir => l10n.water_structure_weir,
    StructureKind.lockGate => l10n.water_structure_lock,
    StructureKind.sluiceGate => l10n.water_structure_sluice,
    StructureKind.culvert => l10n.water_structure_culvert,
  };
}

/// First words of Vietnamese water names that already say what the water is.
const Set<String> _waterWords = {
  'sông', 'kênh', 'kinh', 'rạch', 'xẻo', 'lạch', 'suối', 'mương', 'ngòi', 'hồ', 'ao', //
  'đầm', 'phá', 'bàu', 'biển', 'vịnh', 'vũng', 'cửa', 'cảng', 'bến',
};

IconData waterKindIcon(WaterKind k) => switch (k) {
  WaterKind.sea || WaterKind.lagoon => Icons.waves_rounded,
  WaterKind.dock => Icons.anchor_rounded,
  WaterKind.lake || WaterKind.pond || WaterKind.reservoir => Icons.water_drop_rounded,
  WaterKind.land => Icons.landscape_rounded,
  WaterKind.unknown => Icons.help_outline_rounded,
  _ => Icons.water_rounded,
};

IconData tideVerdictIcon(TideVerdict v) => switch (v) {
  TideVerdict.tidal || TideVerdict.weak => Icons.swap_vert_rounded,
  TideVerdict.none => Icons.block_rounded,
  TideVerdict.unknown => Icons.help_outline_rounded,
};
