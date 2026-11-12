import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/geo/admin_units.dart';

/// Wards/communes and provinces (2025 units) bundled with the app, loaded
/// once on first use: search and "which commune is this point in" work
/// offline. Shared by the map search and the place sheets.
final FutureProvider<AdminIndex> adminIndexProvider = FutureProvider(
  (ref) async =>
      parseAdminIndex(await rootBundle.loadString('assets/data/admin.json', cache: false)),
);
