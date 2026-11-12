import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/navigation/fish_time.dart';
import 'package:rivertide/features/map/application/weather_layer.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Below this zoom pins are clustered: no full (weather) scores are fetched.
const double fishFullScoreMinZoom = 8;

/// Fishing score of [s] at the hour chosen on the map (P2-20).
///
/// Stations near the view use the full score (tide + astronomy + weather),
/// the same number their "Cá ăn" card shows; the rest use the quick
/// tide + astronomy score until the user gets close, so opening the map does
/// not cost one weather request per station. Null without a tide curve.
double? stationFishScore(Ref ref, Station s, StationView? view) {
  if (view == null) return null;
  final tide = view.tide.data;
  if (tide.prediction == null && tide.dailyExtremes == null) return null;
  final hour = fishHourUtc(view.nowUtc, ref.watch(fishTimeProvider));
  if (_near(ref.watch(mapCameraProvider), s.lat, s.lon)) {
    final full = ref.watch(stationFishingProvider(s.id)).value;
    final h = full?.hours.firstWhereOrNull((x) => x.hourUtc == hour);
    if (h != null) return h.score;
  }
  return scoreStationHourQuick(tide, hour).score;
}

/// Roughly within the visible area (a phone screen is ~1.6 tiles wide).
bool _near(MapCamera? cam, double lat, double lon) {
  if (cam == null || cam.zoom < fishFullScoreMinZoom) return false;
  final spanDeg = 360 / (1 << cam.zoom.floor()) * 1.6;
  return (cam.lat - lat).abs() < spanDeg && (cam.lon - lon).abs() < spanDeg;
}
