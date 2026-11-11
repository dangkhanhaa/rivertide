import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/features/map/domain/place.dart';

/// Bundled place names (≈21 000, OpenStreetMap), loaded on the first search
/// and kept: search works with no network.
final FutureProvider<List<Place>> placeIndexProvider = FutureProvider(
  (ref) async => parsePlaces(await rootBundle.loadString('assets/data/places.json', cache: false)),
);
