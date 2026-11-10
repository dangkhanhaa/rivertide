import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/river/river_curve.dart';
import 'package:rivertide/core/calc/river/river_line.dart';
import 'package:rivertide/core/calc/river/river_reach.dart';
import 'package:rivertide/core/calc/tide/tide_series.dart';

final _t0 = DateTime.utc(2026, 11);
const _period = 24.84;

HourlySignal _sea() => HourlySignal(
  startUtc: _t0,
  values: [for (var h = 0; h < 400; h++) 80 * math.sin(2 * math.pi * h / _period)],
);

RiverFit _fit() =>
    RiverFit(lagHours: 8.5, gain: 0.3, intercept: 150, slopeCmPerH: 0, t0Utc: _t0, rmsCm: 9);

void main() {
  final sea = _sea();
  final t = _t0.add(const Duration(hours: 100));

  test('at the station the reach equals the station model', () {
    final r = RiverReach(fit: _fit(), stationKm: 165.6, pointKm: 165.6);
    expect(r.levelAt(t, sea), closeTo(_fit().levelAt(t, sea)!, 1e-9));
    expect(r.lagShiftMinutes, closeTo(0, 1e-9));
    expect(r.meanShiftCm(t), closeTo(0, 1e-9));
  });

  test('at the mouth the reach equals the sea tide (mean 0, gain 1, no lag)', () {
    final r = RiverReach(fit: _fit(), stationKm: 165.6, pointKm: 1e-9);
    expect(r.levelAt(t, sea), closeTo(sea.at(t)!, 1e-6));
    expect(r.gain, closeTo(1, 1e-9));
  });

  test('Thanh Trì (5,7 km downstream of Hà Nội): turns ~17 min earlier, ~5 cm lower', () {
    final r = RiverReach(fit: _fit(), stationKm: 165.6, pointKm: 159.9);
    expect(r.alongKm, closeTo(-5.7, 1e-9));
    expect(r.celerityKmH, closeTo(165.6 / 8.5, 1e-9));
    expect(r.lagShiftMinutes, closeTo(-5.7 / (165.6 / 8.5) * 60, 1e-6));
    expect(r.lagShiftMinutes, inInclusiveRange(-19, -16));
    expect(r.meanShiftCm(t), closeTo(150 * (159.9 / 165.6 - 1), 1e-9));
    expect(r.gain, greaterThan(0.3)); // tide a bit stronger nearer the sea
  });

  test('downstream extremes come earlier by the lag shift', () {
    final up = RiverReach(fit: _fit(), stationKm: 165.6, pointKm: 165.6);
    final down = RiverReach(fit: _fit(), stationKm: 165.6, pointKm: 145.6);
    final from = _t0.add(const Duration(hours: 40));
    final to = _t0.add(const Duration(hours: 120));
    final a = up.series(sea, from, to)!.extremes.firstWhere((e) => e.kind == TideExtremeKind.high);
    final b = down
        .series(sea, from, to)!
        .extremes
        .firstWhere(
          (e) =>
              e.kind == TideExtremeKind.high &&
              e.timeUtc.isAfter(a.timeUtc.subtract(const Duration(hours: 6))),
        );
    final shiftMin = b.timeUtc.difference(a.timeUtc).inMinutes;
    expect(shiftMin, closeTo(down.lagShiftMinutes, 15)); // hourly sampling + parabolic refine
  });

  test('range limits', () {
    expect(RiverReach(fit: _fit(), stationKm: 165.6, pointKm: 190).inRange, isTrue);
    expect(RiverReach(fit: _fit(), stationKm: 165.6, pointKm: 191).inRange, isFalse);
    expect(RiverReach(fit: _fit(), stationKm: 165.6, pointKm: 105).inRange, isFalse);
  });

  group('RiverLine.project', () {
    final line = RiverLine(
      id: 'x',
      name: 'X',
      mouth: 'M',
      points: const [
        (lat: 0, lon: 0, km: 0),
        (lat: 0, lon: 0.1, km: 11.13),
        (lat: 0.1, lon: 0.1, km: 22.19),
      ],
      stationKm: const {'s': 11.13},
    );

    test('on the line', () {
      final p = line.project(0, 0.05);
      expect(p.km, closeTo(5.565, 0.01));
      expect(p.offsetKm, closeTo(0, 1e-9));
    });

    test('off the line: distance and nearest km', () {
      final p = line.project(0.05, 0.11);
      expect(p.offsetKm, closeTo(1.11, 0.02));
      expect(p.km, closeTo(11.13 + 5.53, 0.05));
    });

    test('rejects bad lines', () {
      expect(
        () => RiverLine(
          id: 'b',
          name: 'B',
          mouth: 'M',
          points: const [(lat: 0, lon: 0, km: 0)],
          stationKm: const {},
        ),
        throwsArgumentError,
      );
    });
  });
}
