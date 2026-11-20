import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/weather/wx_codes.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/application/forecast_provider.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/forecast_hourly.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/forecast_parts.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/weather_glyph.dart';
import 'package:rivertide/features/stations/presentation/widgets/forecast/wx_text.dart';

/// Hours shown in the map sheet; the full 48 h and 7 days are in "Xem chi tiết".
const int _compactHours = 24;

/// Weather in a map sheet: now in one line, the most important advice and
/// the next 24 hours.
class ForecastCompact extends StatelessWidget {
  const ForecastCompact({required this.forecast, super.key});

  final StationForecast forecast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final f = forecast;
    final now = f.now;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            Text('${l10n.wx_title} · ${l10n.wx_forecastTag}', style: context.text.label),
            if (now != null) _NowLine(forecast: f),
            if (f.advice.isNotEmpty) WxAdviceCard(advice: f.advice, max: 1, showTitle: false),
            if (f.hours.isNotEmpty)
              HourlyStrip(hours: f.hours.take(_compactHours).toList(), nowUtc: f.nowUtc),
            WxSourceLine(forecast: f),
          ],
        ),
      ),
    );
  }
}

class _NowLine extends StatelessWidget {
  const _NowLine({required this.forecast});

  final StationForecast forecast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = forecast.now;
    if (now == null) return const SizedBox.shrink();
    final h = now.hour;
    final sky = skyOf(h.code);
    final isDay = h.isDay ?? true;
    final temp = h.tempC;
    final wind = h.windKmh;
    final dir = h.windFromDeg;
    final soon = now.rainProbSoonPct;
    final details = [
      if (h.feelsC case final x?) l10n.wx_feels('${x.round()}'),
      if (wind != null)
        '${l10n.wx_wind} ${dir == null ? l10n.wx_kmh(wind.round()) : l10n.wx_windValue(context.compassText(compassOf(dir)), wind.round())}',
      if (soon != null) '${l10n.wx_rainSoon} ${l10n.wx_percent(soon.round())}',
    ];
    return Row(
      spacing: AppSpacing.md,
      children: [
        WeatherGlyph(sky: sky, isDay: isDay, size: AppIconSize.lg * 1.25),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${temp == null ? '—' : '${temp.round()}°'} · ${context.skyText(sky, isDay: isDay)}',
                style: context.text.headline,
              ),
              Text(joinPhrases(details), style: context.text.caption),
            ],
          ),
        ),
      ],
    );
  }
}
