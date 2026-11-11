import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/astro/moon.dart';
import 'package:rivertide/core/calc/tide/tide_state.dart';
import 'package:rivertide/core/db/app_database.dart';
import 'package:rivertide/features/stations/stations.dart';

/// The fishing log, newest first (stored only on this device).
final StreamProvider<List<CatchEntry>> catchesProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(appDatabaseProvider).watchCatches(),
);

/// What the user typed for one catch.
class CatchInput {
  const CatchInput({
    required this.placeId,
    required this.placeName,
    required this.lat,
    required this.lon,
    required this.caughtAtUtc,
    required this.species,
    this.weightKg,
    this.lengthCm,
    this.bait,
    this.note,
    this.photo,
  });

  final String placeId;
  final String placeName;
  final double lat;
  final double lon;
  final DateTime caughtAtUtc;
  final String species;
  final double? weightKg;
  final double? lengthCm;
  final String? bait;
  final String? note;
  final Uint8List? photo;
}

/// Saves [input] with the place's conditions at the catch time: level and
/// direction from its curve, weather and fishing score of that hour, moon.
Future<void> saveCatch(WidgetRef ref, CatchInput input) async {
  final t = input.caughtAtUtc;
  final hour = DateTime.utc(t.year, t.month, t.day, t.hour);
  StationView? view;
  StationFishing? fishing;
  try {
    view = await ref.read(stationViewProvider(input.placeId).future);
    fishing = await ref.read(stationFishingProvider(input.placeId).future);
  } on Exception {
    // Offline or no data for the place: the catch is still saved, without conditions.
  }
  final prediction = view?.tide.data.prediction;
  final rate = prediction?.rateCmPerHAt(t);
  final weather = fishing?.weather.firstWhereOrNull((w) => w.timeUtc == hour);
  await ref
      .read(appDatabaseProvider)
      .addCatch(
        CatchesCompanion.insert(
          placeId: input.placeId,
          placeName: input.placeName,
          lat: input.lat,
          lon: input.lon,
          caughtAtUtc: t,
          species: input.species,
          weightKg: Value(input.weightKg),
          lengthCm: Value(input.lengthCm),
          bait: Value(input.bait),
          note: Value(input.note),
          photo: Value(input.photo),
          levelCm: Value(prediction?.levelAt(t)),
          waterState: Value(rate == null ? null : classifyRate(rate).name),
          temperatureC: Value(weather?.temperatureC),
          windKmh: Value(weather?.windKmh),
          moonPhase: Value(moonIllumination(t).phase),
          fishingScore: Value(fishing?.hours.firstWhereOrNull((h) => h.hourUtc == hour)?.score),
        ),
      );
}

Future<void> deleteCatch(WidgetRef ref, int id) => ref.read(appDatabaseProvider).deleteCatch(id);
