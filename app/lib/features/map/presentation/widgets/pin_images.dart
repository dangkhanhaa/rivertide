import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:rivertide/core/calc/fishing/fish_activity.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';
import 'package:rivertide/features/map/presentation/widgets/fish_pin_icons.dart';
import 'package:rivertide/features/map/presentation/widgets/overlay_layers.dart';

/// Registers every pin image the map layers refer to (stations by fish band
/// and trend, flood alarms, community spots, trips, ponds).
Future<void> addPinImages(MapLibreMapController c, MarkerPalette p, double ratio) async {
  for (final a in [null, ...FishActivity.values]) {
    final style = (
      fill: a == null ? p.fishNone : p.fish[a.index],
      ink: p.stroke,
      shadow: p.shadow,
      glow: a == FishActivity.peak,
    );
    for (final t in MarkerTrend.values) {
      final png = await fishPinPng(style, t, ratio, fishes: a == null ? 1 : 2);
      await c.addImage(fishPinName(a, t), png, false, ratio);
    }
  }
  for (final s in [MarkerStatus.alarm1, MarkerStatus.alarm2, MarkerStatus.alarm3]) {
    final style = (fill: p.status[s] ?? p.pin, ink: p.stroke, shadow: p.shadow, glow: false);
    for (final t in MarkerTrend.values) {
      await c.addImage(alarmPinName(s, t), await fishPinPng(style, t, ratio), false, ratio);
    }
  }
  final spot = (fill: p.community, ink: p.stroke, shadow: p.shadow, glow: false);
  final png = await fishPinPng(spot, MarkerTrend.unknown, ratio, fishes: 1, star: true);
  await c.addImage(communityPinImage, png, false, ratio);
  final trip = (fill: p.trip, ink: p.stroke, shadow: p.shadow, glow: false);
  final tripPng = await fishPinPng(trip, MarkerTrend.unknown, ratio, glyph: PinGlyph.people);
  await c.addImage(tripPinImage, tripPng, false, ratio);
  final pond = (fill: p.pond, ink: p.stroke, shadow: p.shadow, glow: false);
  await c.addImage(
    pondPinImage,
    await fishPinPng(pond, MarkerTrend.unknown, ratio, fishes: 1, star: true),
    false,
    ratio,
  );
}
