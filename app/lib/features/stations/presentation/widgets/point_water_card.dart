import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/geo/tide_verdict.dart';
import 'package:rivertide/core/calc/geo/tide_zones.dart';
import 'package:rivertide/core/calc/geo/water_kind.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/water_providers.dart';
import 'package:rivertide/features/stations/domain/point_water.dart';
import 'package:rivertide/features/stations/presentation/widgets/water_text.dart';

/// What water a map point is on and whether the tide reaches it, in words
/// with icons (P2-50), plus a safety note near dams and sluices (P2-52).
class PointWaterCard extends ConsumerWidget {
  const PointWaterCard({required this.stationId, required this.water, super.key});

  final String stationId;
  final PointWater water;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final osm = ref.watch(pointSurroundingsProvider(stationId));
    final c = context.colors;
    final structures = osm.value?.structures ?? const <WaterStructure>[];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          _IconLine(
            icon: waterKindIcon(water.kind),
            text: context.waterTitle(water.kind, water.name),
            style: context.text.title,
          ),
          // Land has no tide line; "unknown water, unknown tide" says it twice.
          if (water.kind != WaterKind.land && water.verdict != TideVerdict.unknown ||
              water.kind.isFlowing)
            _IconLine(
              icon: tideVerdictIcon(water.verdict),
              text: context.tideVerdictText(water.verdict),
              style: context.text.bodyStrong,
            ),
          Text(context.tideReasonText(water), style: context.text.body),
          if (water.verdict == TideVerdict.none && water.kind != WaterKind.land)
            Text(context.l10n.water_noTideNote, style: context.text.caption),
          if (osm.isLoading && water.kind == WaterKind.unknown)
            Text(context.l10n.water_checking, style: context.text.caption),
          for (final s in structures) StructureNote(structure: s),
          Text(context.l10n.water_source, style: context.text.caption),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text, required this.style});

  final IconData icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: AppIconSize.sm, color: context.colors.primary),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(text, style: style)),
    ],
  );
}

/// "Gần cống Rạch Chiếc (cách 120 m): dòng chảy mạnh…" with a warning icon.
class StructureNote extends StatelessWidget {
  const StructureNote({required this.structure, super.key});

  final WaterStructure structure;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final name = structure.name;
    final m = structure.distanceM;
    final text = context.l10n.water_structure(
      context.structureName(structure.kind),
      name == null ? '' : ' $name',
      '${m == null ? '≤ ' : ''}${LevelFormat.distanceM(m ?? structureRadiusM)}',
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning_amber_rounded, size: AppIconSize.sm, color: c.alarm2),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: context.text.bodyStrong)),
      ],
    );
  }
}

/// A tap on land: say so, and offer the water drawn nearby (P2-50).
class LandNotice extends StatelessWidget {
  const LandNotice({required this.nearby, this.onPick, super.key});

  final List<NearbyWater> nearby;
  final ValueChanged<NearbyWater>? onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pick = onPick;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.land_hint, style: context.text.body),
        if (nearby.isNotEmpty && pick != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.land_nearby, style: context.text.label),
          for (final w in nearby)
            ListTile(
              contentPadding: EdgeInsets.zero,
              minTileHeight: AppSpacing.minTouch,
              leading: Icon(waterKindIcon(w.kind)),
              title: Text(
                l10n.land_nearbyItem(
                  // Named as the verdict will read it (a southern stream is a rạch).
                  context.waterTitle(
                    effectiveWaterKind(w.kind, w.name, tideZoneAt(w.lat, w.lon)),
                    w.name,
                  ),
                  LevelFormat.distanceM(w.distanceM),
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => pick(w),
            ),
        ],
      ],
    );
  }
}
