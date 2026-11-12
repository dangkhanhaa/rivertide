import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';
import 'package:rivertide/features/map/presentation/widgets/base_map.dart';

/// Map layer colours from theme tokens (CLAUDE.md 3.4).
MarkerPalette markerPalette(AppColors c) => (
  status: {
    MarkerStatus.stale: c.stale,
    MarkerStatus.normal: c.ok,
    MarkerStatus.alarm1: c.alarm1,
    MarkerStatus.alarm2: c.alarm2,
    MarkerStatus.alarm3: c.alarm3,
  },
  stroke: c.surface,
  label: c.onSurface,
  labelHalo: c.surface,
  me: c.water,
  pin: c.alarm2,
  river: c.water,
  flowRising: c.water,
  flowFalling: c.alarm2,
  flowSlack: c.stale,
  community: c.spot,
  fish: [c.fishLow, c.fishFair, c.fishGood, c.fishPeak],
  fishNone: c.stale,
  shadow: c.onSurface.withValues(alpha: 0.35),
);
