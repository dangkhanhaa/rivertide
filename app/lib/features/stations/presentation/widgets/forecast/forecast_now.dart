import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/weather/wx_codes.dart';
import 'package:rivertide/core/calc/weather/wx_now.dart';
import 'package:rivertide/core/format/level_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/core/widgets/ui_kit.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/weather_glyph.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/wx_text.dart';

/// Visibility shown only when it matters (haze, fog, heavy rain).
const double _showVisibilityBelowM = 10000;

/// "Bây giờ": big temperature, sky, feels-like and the numbers anglers ask
/// for, on the accent gradient used by every tab's hero.
class ForecastNow extends StatelessWidget {
  const ForecastNow({required this.now, super.key});

  final WxNow now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final white = context.colors.surface;
    final h = now.hour;
    final sky = skyOf(h.code);
    final isDay = h.isDay ?? true;
    final temp = h.tempC;
    final feels = h.feelsC;
    final skyText = context.skyText(sky, isDay: isDay);
    return HeroPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          Text(
            '${l10n.wx_now} · ${l10n.wx_forecastTag}',
            style: context.text.label.copyWith(color: white.withValues(alpha: 0.9)),
          ),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  label: '${l10n.wx_now}: ${temp == null ? '—' : '${temp.round()}°'}, $skyText',
                  excludeSemantics: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temp == null ? '—' : '${temp.round()}°',
                        style: context.text.displayLevel.copyWith(color: white),
                      ),
                      Text(skyText, style: context.text.title.copyWith(color: white)),
                      if (feels != null)
                        Text(
                          l10n.wx_feels('${feels.round()}'),
                          style: context.text.body.copyWith(color: white.withValues(alpha: 0.9)),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: white, shape: BoxShape.circle),
                child: WeatherGlyph(sky: sky, isDay: isDay, size: AppIconSize.lg * 1.5),
              ),
            ],
          ),
          _Metrics(now: now),
        ],
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.now});

  final WxNow now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final h = now.hour;
    final wind = h.windKmh;
    final dir = h.windFromDeg;
    final uv = h.uv;
    final p = h.pressureHpa;
    final trend = now.trend;
    final soon = now.rainProbSoonPct;
    final vis = h.visibilityM;
    final tiles = <Widget>[
      if (h.humidityPct case final x?)
        _Tile(
          icon: Icons.water_drop_outlined,
          label: l10n.wx_humidity,
          value: l10n.wx_percent(x.round()),
        ),
      if (wind != null)
        _Tile(
          icon: Icons.air_rounded,
          label: l10n.wx_wind,
          value: dir == null
              ? l10n.wx_kmh(wind.round())
              : l10n.wx_windValue(context.compassText(compassOf(dir)), wind.round()),
          detail: l10n.wx_force(beaufort(wind)),
          arrowFromDeg: dir,
        ),
      if (h.gustKmh case final g?)
        _Tile(
          icon: Icons.storm_rounded,
          label: l10n.wx_gust,
          value: l10n.wx_kmh(g.round()),
          detail: l10n.wx_force(beaufort(g)),
        ),
      if (soon != null)
        _Tile(
          icon: Icons.umbrella_rounded,
          label: l10n.wx_rainSoon,
          value: l10n.wx_percent(soon.round()),
        ),
      if (uv != null)
        _Tile(
          icon: Icons.wb_sunny_outlined,
          label: l10n.wx_uv,
          value: '${uv.round()}',
          detail: context.uvText(uv),
        ),
      if (p != null)
        _Tile(
          icon: Icons.speed_rounded,
          label: l10n.wx_pressure,
          value: l10n.wx_hpa(p.round()),
          detail: trend == null ? null : l10n.wx_trend24h(context.trendText(trend)),
        ),
      if (vis != null && vis < _showVisibilityBelowM)
        _Tile(
          icon: Icons.visibility_rounded,
          label: l10n.wx_visibility,
          value: l10n.wx_km(LevelFormat.decimal1(vis / 1000)),
        ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final half = (box.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [for (final t in tiles) SizedBox(width: half, child: t)],
        );
      },
    );
  }
}

/// One number on the hero: icon, label, value, optional small detail.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
    this.arrowFromDeg,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;

  /// Wind "from" direction; the arrow points where the wind goes.
  final double? arrowFromDeg;

  @override
  Widget build(BuildContext context) {
    final white = context.colors.surface;
    final from = arrowFromDeg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.sm,
        children: [
          if (from == null)
            Icon(icon, size: AppIconSize.sm, color: white)
          else
            Transform.rotate(
              angle: (from + 180) * math.pi / 180,
              child: Icon(Icons.north_rounded, size: AppIconSize.sm, color: white),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.caption.copyWith(color: white.withValues(alpha: 0.85)),
                ),
                Text(value, style: context.text.bodyStrong.copyWith(color: white)),
                if (detail case final d?)
                  Text(
                    d,
                    style: context.text.caption.copyWith(color: white.withValues(alpha: 0.85)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
