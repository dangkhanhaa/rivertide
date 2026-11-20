import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/weather/wx_codes.dart';
import 'package:rivertide/core/theme/app_colors.dart';

/// Weather icon built from Material symbols: a main shape plus a small
/// badge (sun or moon behind a cloud, a drop under a cloud), so partly
/// cloudy and rain read at a glance. Decorative: callers give the words.
class WeatherGlyph extends StatelessWidget {
  const WeatherGlyph({required this.sky, this.isDay = true, this.size = 24, super.key});

  final WxSky? sky;
  final bool isDay;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sun = isDay ? Icons.wb_sunny_rounded : Icons.bedtime_rounded;
    final sunColor = isDay ? c.alarm1 : c.tidePred;
    final cloud = c.stale;
    final drop = c.water;
    final (
      IconData main,
      Color mainColor,
      IconData? badge,
      Color? badgeColor,
      bool badgeTop,
    ) = switch (sky) {
      null => (Icons.cloud_queue_rounded, cloud, null, null, false),
      WxSky.clear => (sun, sunColor, null, null, false),
      WxSky.mainlyClear || WxSky.partlyCloudy => (Icons.cloud_rounded, cloud, sun, sunColor, true),
      WxSky.overcast => (Icons.cloud_rounded, cloud, null, null, false),
      WxSky.fog => (Icons.foggy, cloud, null, null, false),
      WxSky.snow => (Icons.cloudy_snowing, cloud, null, null, false),
      WxSky.thunderstorm ||
      WxSky.thunderstormHail => (Icons.thunderstorm_rounded, c.alarm2, null, null, false),
      WxSky.showersLight ||
      WxSky.showers ||
      WxSky.showersHeavy => (Icons.cloud_rounded, cloud, Icons.water_drop_rounded, drop, false),
      _ => (Icons.cloud_rounded, cloud, Icons.water_drop_rounded, drop, false),
    };
    final small = size * 0.55;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (badge != null && badgeTop)
              Positioned(
                left: 0,
                top: 0,
                child: Icon(badge, size: small, color: badgeColor),
              ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  left: badgeTop ? size * 0.18 : 0,
                  top: badgeTop ? size * 0.18 : 0,
                  bottom: badge != null && !badgeTop ? size * 0.22 : 0,
                ),
                child: FittedBox(child: Icon(main, color: mainColor)),
              ),
            ),
            if (badge != null && !badgeTop)
              Positioned(
                right: size * 0.05,
                bottom: 0,
                child: Icon(badge, size: small * 0.8, color: badgeColor),
              ),
          ],
        ),
      ),
    );
  }
}
