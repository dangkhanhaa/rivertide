import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/river/river_curve.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';

final _t0 = DateTime.utc(2026, 11);

HourlySignal _sine({double amp = 80, double periodH = 24.84}) => HourlySignal(
  startUtc: _t0,
  values: [for (var h = 0; h < 400; h++) amp * math.sin(2 * math.pi * h / periodH)],
);

void main() {
  group('HourlySignal.at', () {
    final s = HourlySignal(startUtc: _t0, values: [0, 10, null, 30]);
    test('interpolates linearly, null across gaps and outside', () {
      expect(s.at(_t0.add(const Duration(minutes: 30))), 5);
      expect(s.at(_t0.add(const Duration(minutes: 90))), isNull);
      expect(s.at(_t0.subtract(const Duration(minutes: 1))), isNull);
      expect(s.at(_t0.add(const Duration(hours: 3))), 30);
      expect(s.at(_t0.add(const Duration(hours: 4))), isNull);
    });
  });

  test('fit recovers lag, gain and trend from 6-hourly samples', () {
    final sea = _sine();
    final points = [
      for (var h = 100; h <= 196; h += 6)
        RiverPoint(
          timeUtc: _t0.add(Duration(hours: h)),
          levelCm: 150 + 0.1 * (h - 100) + 0.5 * (sea.at(_t0.add(Duration(hours: h - 9))) ?? 0),
          observed: true,
        ),
    ];
    final fit = fitTidalRiver(points, sea);
    expect(fit, isNotNull);
    expect(fit!.lagHours, 9);
    expect(fit.gain, closeTo(0.5, 1e-6));
    expect(fit.slopeCmPerH, closeTo(0.1, 1e-6));
    expect(fit.rmsCm, closeTo(0, 1e-6));
  });

  test('fit refuses too few points and inverted tide', () {
    final sea = _sine();
    final few = [
      for (var h = 0; h < 5; h++)
        RiverPoint(timeUtc: _t0.add(Duration(hours: 100 + h * 6)), levelCm: 100, observed: true),
    ];
    expect(fitTidalRiver(few, sea), isNull);
    final inverted = [
      for (var h = 100; h <= 196; h += 6)
        RiverPoint(
          timeUtc: _t0.add(Duration(hours: h)),
          levelCm: 150 - 0.8 * (sea.at(_t0.add(Duration(hours: h))) ?? 0),
          observed: true,
        ),
    ];
    // Only a lag of ~half a period could fake it; the gain sign must stay positive.
    final f = fitTidalRiver(inverted, sea);
    expect(f == null || f.gain > 0, isTrue);
  });

  group('pchipAt', () {
    final xs = <double>[0, 6, 12, 18];
    final ys = <double>[100, 180, 160, 90];
    test('passes through the points and stays within neighbours', () {
      for (var i = 0; i < xs.length; i++) {
        expect(pchipAt(xs, ys, xs[i]), closeTo(ys[i], 1e-9));
      }
      for (var x = 0.0; x <= 18; x += 0.5) {
        final v = pchipAt(xs, ys, x);
        expect(v, inInclusiveRange(90, 180), reason: 'x=$x');
      }
    });

    test('flat beyond the ends', () {
      expect(pchipAt(xs, ys, -5), 100);
      expect(pchipAt(xs, ys, 30), 90);
    });
  });

  test('non-tidal station: monotone curve, no invented extremes on a rising run', () {
    final points = [
      for (final (h, v) in [(0, 100.0), (6, 110.0), (12, 130.0), (18, 160.0)])
        RiverPoint(
          timeUtc: _t0.add(Duration(hours: h)),
          levelCm: v,
          observed: true,
        ),
    ];
    final r = buildRiverSeries(points: points, tidal: false);
    expect(r, isNotNull);
    expect(r!.fit, isNull);
    expect(r.series.extremes, isEmpty);
    expect(r.series.levelsCm.first, 100);
    expect(r.series.levelsCm.last, 160);
  });

  test('real data: Hà Nội bulletin 09/11/2026 + Open-Meteo Hòn Dấu', () {
    final bulletin = jsonDecode(
      File('test/fixtures/kttv_tvhn_20261109.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final hn = (bulletin['stations']! as List<Object?>).cast<Map<String, Object?>>().firstWhere(
      (s) => s['name'] == 'HàNội',
    );
    final points = [
      for (final p in (hn['points']! as List<Object?>).cast<Map<String, Object?>>())
        RiverPoint(
          timeUtc: DateTime.parse(p['t']! as String),
          levelCm: (p['v']! as num).toDouble(),
          observed: p['kind'] == 'obs',
        ),
    ];
    final om = jsonDecode(
      File('test/fixtures/om_hondau_20261025_20261112.json').readAsStringSync(),
    ) as Map<String, Object?>;
    final hourly = om['hourly']! as Map<String, Object?>;
    final sea = HourlySignal(
      startUtc: DateTime.parse('${(hourly['time']! as List<Object?>).first}Z'),
      values: [
        for (final v in hourly['sea_level_height_msl']! as List<Object?>)
          if (v case final num n) n * 100 else null,
      ],
    );
    final r = buildRiverSeries(points: points, tidal: true, sea: sea);
    expect(r, isNotNull);
    // Same answer as the Python prototype (lag 8 h, gain ≈ 0,3).
    expect(r!.fit?.lagHours, 8);
    expect(r.fit?.gain, closeTo(0.3, 0.05));
    final highs = r.series.extremes.where((e) => e.kind == TideExtremeKind.high).toList();
    final lows = r.series.extremes.where((e) => e.kind == TideExtremeKind.low).toList();
    expect(highs, isNotEmpty);
    expect(lows, isNotEmpty);
    // Python prototype: low ≈ 118 cm at 17:00 UTC 09/11 (00:00 VN 10/11).
    final low = lows.firstWhere((e) => e.timeUtc.isAfter(DateTime.utc(2026, 11, 9, 8)));
    expect(low.timeUtc.difference(DateTime.utc(2026, 11, 9, 17)).inMinutes.abs(), lessThan(90));
    expect(low.levelCm, closeTo(118, 3));
  });
}
