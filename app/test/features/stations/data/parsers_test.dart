import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/tide/observation.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/features/stations/data/ioc_parser.dart';
import 'package:rivertide/features/stations/data/marine_series.dart';
import 'package:rivertide/features/stations/data/observation_codec.dart';
import 'package:rivertide/features/stations/data/open_meteo_parser.dart';
import 'package:rivertide/features/stations/data/tide_asset_parser.dart';
import 'package:rivertide/features/stations/domain/station_tide.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  group('parseIocObservations', () {
    test('real fixture: 10-minute bins for ra2 only, metres → cm + datum offset', () {
      final obs = parseIocObservations(
        fixture('vung_20261104.json'),
        sensor: 'ra2',
        datumOffsetCm: 6.6,
      );
      expect(obs.length, inInclusiveRange(130, 146)); // one day of 10-minute bins
      expect(obs.first.timeUtc.isUtc, isTrue);
      expect(obs.first.timeUtc.minute % 10, 0);
      for (final o in obs) {
        expect(o.levelCm, inInclusiveRange(-100, 600));
      }
      final raw = parseIocObservations(
        fixture('vung_20261104.json'),
        sensor: 'ra2',
        datumOffsetCm: 0,
      );
      expect(obs.first.levelCm - raw.first.levelCm, closeTo(6.6, 1e-9));
    });

    test('rejects malformed JSON and non-list bodies', () {
      expect(
        () => parseIocObservations('{oops', sensor: 'ra2', datumOffsetCm: 0),
        throwsA(isA<ParseException>()),
      );
      expect(
        () => parseIocObservations('{"a":1}', sensor: 'ra2', datumOffsetCm: 0),
        throwsA(isA<ParseException>()),
      );
    });

    test('drops out-of-range, wrong-typed and spiky samples', () {
      final rows = [
        for (var m = 0; m < 30; m++)
          '{"slevel":${m == 12 ? 9.9 : 2.0},"stime":"2026-11-04 00:${m.toString().padLeft(2, '0')}:00","sensor":"ra2"}',
        '{"slevel":99,"stime":"2026-11-04 00:31:00","sensor":"ra2"}',
        '{"slevel":"x","stime":"2026-11-04 00:32:00","sensor":"ra2"}',
      ];
      final obs = parseIocObservations('[${rows.join(',')}]', sensor: 'ra2', datumOffsetCm: 0);
      for (final o in obs) {
        expect(o.levelCm, closeTo(200, 80), reason: 'spike diluted or removed, 99 m rejected');
      }
    });
  });

  group('Open-Meteo', () {
    test('forecast fixture: local times converted to UTC using utc_offset_seconds', () {
      final hours = parseWeather(fixture('forecast_cantho_20261106.json'));
      expect(hours.first.timeUtc, DateTime.utc(2026, 11, 4, 17));
      expect(hours.where((h) => h.windKmh != null), isNotEmpty);
      expect(hours.where((h) => h.weatherCode != null), isNotEmpty);
    });

    test('marine fixture → hourly series with extremes', () {
      final sea = parseMarineSeaLevel(fixture('marine_vungtau_20261106.json'));
      final series = marineToSeries(sea);
      expect(series, isNotNull);
      expect(series!.stepMinutes, 60);
      expect(series.extremes, isNotEmpty);
    });

    test('bad payloads throw ParseException', () {
      expect(() => parseWeather('[]'), throwsA(isA<ParseException>()));
      expect(
        () => parseWeather('{"utc_offset_seconds":0,"hourly":{"time":["bad"]}}'),
        throwsA(isA<ParseException>()),
      );
    });

    test('marineToSeries keeps the longest gap-free run, null if < 24 h', () {
      final t0 = DateTime.utc(2026, 11);
      List<(DateTime, double?)> run(int n, {int? gapAt}) => [
        for (var i = 0; i < n; i++) (t0.add(Duration(hours: i)), i == gapAt ? null : 100.0 + i),
      ];
      expect(marineToSeries(run(20)), isNull);
      final s = marineToSeries(run(60, gapAt: 10))!;
      expect(s.startUtc, t0.add(const Duration(hours: 11)));
      expect(s.levelsCm.length, 49);
    });
  });

  group('tide asset', () {
    test('bundled Vũng Tàu 2026 file parses and covers the whole year', () {
      final asset = parseTideAsset(File('assets/tide/ioc-vung_2026.json').readAsStringSync());
      expect(asset.series.startUtc, DateTime.utc(2026));
      expect(asset.series.levelsCm.length, 365 * 144);
      expect(asset.series.extremes.length, greaterThan(1300));
      expect(asset.model.rmseCm, isNotNull);
      expect(asset.model.confidence, isA<TideConfidence>());
    });

    test('rejects bad headers and rows', () {
      expect(() => parseTideAsset('{}'), throwsA(isA<ParseException>()));
      const bad =
          '{"start":"2026-01-01T00:00:00Z","step_minutes":10,"levels_cm":[1,"x"],'
          '"extremes":[],"model":{}}';
      expect(() => parseTideAsset(bad), throwsA(isA<ParseException>()));
    });
  });

  group('observation cache codec', () {
    test('round-trips with 1 mm precision and merges/trims by time', () {
      final t = DateTime.utc(2026, 11, 9);
      final a = [WaterObservation(timeUtc: t, levelCm: 123.45)];
      expect(decodeObservations(encodeObservations(a)).single.levelCm, closeTo(123.5, 0.051));
      final old = [
        WaterObservation(timeUtc: t.subtract(const Duration(days: 40)), levelCm: 1),
        ...a,
      ];
      final fresh = [WaterObservation(timeUtc: t, levelCm: 200)];
      final merged = mergeObservations(old, fresh, t.subtract(const Duration(days: 30)));
      expect(merged.single.levelCm, 200);
      expect(decodeObservations('not json'), isEmpty);
    });
  });

  test('Open-Meteo cell and terrain height: land vs sea', () {
    final land = parseOpenMeteoCell(fixture('marine_thaibinh_20261110.json'))!;
    expect(land.elevationM, 11);
    expect(land.lat, closeTo(20.458, 0.001));
    final sea = parseOpenMeteoCell(fixture('marine_sea_offvungtau_20261110.json'))!;
    expect(sea.elevationM, 0);
    expect(parseOpenMeteoCell('[]'), isNull);
    expect(() => parseOpenMeteoCell('{'), throwsA(isA<ParseException>()));
  });
}
