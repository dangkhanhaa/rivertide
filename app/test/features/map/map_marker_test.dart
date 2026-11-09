import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';
import 'package:rivertide/features/map/domain/map_marker.dart';

MapMarker _m(String id, MarkerStatus status, {bool hasTide = true}) => MapMarker(
  id: id,
  name: id,
  lat: 10.34,
  lon: 107.07,
  status: status,
  trend: MarkerTrend.rising,
  hasTide: hasTide,
);

void main() {
  final now = DateTime.utc(2026, 11, 9, 5);

  group('markerStatus', () {
    test('gauge with a recent observation is normal', () {
      expect(
        markerStatus(
          isGauge: true,
          hasData: true,
          lastObservationUtc: now.subtract(const Duration(minutes: 20)),
          nowUtc: now,
        ),
        MarkerStatus.normal,
      );
    });

    test('gauge silent for more than 6 h is grey (AC-MAP01-3)', () {
      expect(
        markerStatus(
          isGauge: true,
          hasData: true,
          lastObservationUtc: now.subtract(const Duration(hours: 6, minutes: 1)),
          nowUtc: now,
        ),
        MarkerStatus.stale,
      );
      expect(
        markerStatus(
          isGauge: true,
          hasData: true,
          lastObservationUtc: now.subtract(const Duration(hours: 6)),
          nowUtc: now,
        ),
        MarkerStatus.normal,
      );
      expect(
        markerStatus(isGauge: true, hasData: true, lastObservationUtc: null, nowUtc: now),
        MarkerStatus.stale,
      );
    });

    test('model point with data is normal; no data at all is grey', () {
      expect(
        markerStatus(isGauge: false, hasData: true, lastObservationUtc: null, nowUtc: now),
        MarkerStatus.normal,
      );
      expect(
        markerStatus(isGauge: false, hasData: false, lastObservationUtc: null, nowUtc: now),
        MarkerStatus.stale,
      );
    });
  });

  test('markerTrend maps every tide state', () {
    expect(markerTrend(null), MarkerTrend.unknown);
    expect(markerTrend(TideState.risingFast), MarkerTrend.rising);
    expect(markerTrend(TideState.rising), MarkerTrend.rising);
    expect(markerTrend(TideState.slack), MarkerTrend.slack);
    expect(markerTrend(TideState.falling), MarkerTrend.falling);
    expect(markerTrend(TideState.fallingFast), MarkerTrend.falling);
  });

  test('severity order lets clusters take the worst member', () {
    expect(MarkerStatus.values.map((s) => s.index), orderedEquals([0, 1, 2, 3, 4]));
    expect(MarkerStatus.alarm3.index > MarkerStatus.alarm2.index, isTrue);
    expect(MarkerStatus.normal.index > MarkerStatus.stale.index, isTrue);
  });

  group('MapFilter', () {
    final all = [
      _m('a', MarkerStatus.normal),
      _m('b', MarkerStatus.stale),
      _m('c', MarkerStatus.alarm2),
      _m('d', MarkerStatus.normal, hasTide: false),
    ];
    List<String> ids(MapFilter f) => all.where(f.accepts).map((m) => m.id).toList();

    test('no filter keeps everything', () {
      expect(ids(const MapFilter()), ['a', 'b', 'c', 'd']);
      expect(const MapFilter().isActive, isFalse);
    });

    test('only alarm keeps yellow/orange/red (AC-MAP01-5)', () {
      expect(ids(const MapFilter(onlyAlarm: true)), ['c']);
    });

    test('hide stale and only tide', () {
      expect(ids(const MapFilter(hideStale: true)), ['a', 'c', 'd']);
      expect(ids(const MapFilter(onlyTide: true)), ['a', 'b', 'c']);
      expect(const MapFilter().copyWith(hideStale: true).isActive, isTrue);
    });
  });

  test('GeoJSON: lon/lat order, integer ids, properties', () {
    final json = markersToGeoJson([_m('ioc-vung', MarkerStatus.stale)]);
    final features = json['features']! as List<Object?>;
    final f = features.single! as Map<String, Object?>;
    expect(f['id'], 0);
    expect((f['geometry']! as Map<String, Object?>)['coordinates'], [107.07, 10.34]);
    expect(f['properties'], {
      'sid': 'ioc-vung',
      'name': 'ioc-vung',
      'sev': 0,
      'arrow': 'arrow-rising',
    });
  });
}
