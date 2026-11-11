import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

/// Raw JSON responses cached per key (V0 offline cache; PROJECT.md 10.4 simplified).
class KvCache extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {cacheKey};
}

/// Stations the user follows, in display order.
class Favorites extends Table {
  TextColumn get stationId => text()();
  IntColumn get sortOrder => integer()();

  /// User's own name for the place ("Hố sâu gốc si"), note, group (v2).
  TextColumn get label => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get groupName => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {stationId};
}

/// Fishing log (P2-04), kept only on this device. Conditions are snapshotted
/// when the catch is saved so the entry stays true after forecasts change.
@DataClassName('CatchEntry')
class Catches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get placeId => text()();
  TextColumn get placeName => text()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();
  DateTimeColumn get caughtAtUtc => dateTime()();
  TextColumn get species => text()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get lengthCm => real().nullable()();
  TextColumn get bait => text().nullable()();
  TextColumn get note => text().nullable()();

  /// Re-encoded JPEG (no EXIF / location metadata).
  BlobColumn get photo => blob().nullable()();
  RealColumn get levelCm => real().nullable()();

  /// TideState name at the time ("rising", "falling", …).
  TextColumn get waterState => text().nullable()();
  RealColumn get temperatureC => real().nullable()();
  RealColumn get windKmh => real().nullable()();

  /// Moon phase 0..1 (0 new, 0.5 full).
  RealColumn get moonPhase => real().nullable()();
  RealColumn get fishingScore => real().nullable()();
}

/// Simple key/value settings.
class Settings extends Table {
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();

  @override
  Set<Column<Object>> get primaryKey => {settingKey};
}

@DriftDatabase(tables: [KvCache, Favorites, Catches, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'rivertide',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // v2: name/note/group for saved places + fishing log. Existing
      // favourites are kept (columns are added, nothing is dropped).
      if (from < 2) {
        await m.addColumn(favorites, favorites.label);
        await m.addColumn(favorites, favorites.note);
        await m.addColumn(favorites, favorites.groupName);
        await m.createTable(catches);
      }
    },
  );

  Stream<List<Favorite>> watchFavorites() =>
      (select(favorites)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();

  /// Empty strings clear a field.
  Future<void> updateFavoriteMeta(String stationId, {String? label, String? note, String? group}) =>
      (update(favorites)..where((t) => t.stationId.equals(stationId))).write(
        FavoritesCompanion(
          label: Value(_blankToNull(label)),
          note: Value(_blankToNull(note)),
          groupName: Value(_blankToNull(group)),
        ),
      );

  Stream<List<CatchEntry>> watchCatches() =>
      (select(catches)..orderBy([(t) => OrderingTerm.desc(t.caughtAtUtc)])).watch();

  Future<int> addCatch(CatchesCompanion entry) => into(catches).insert(entry);

  Future<void> deleteCatch(int id) => (delete(catches)..where((t) => t.id.equals(id))).go();

  Future<KvCacheData?> readCache(String key) =>
      (select(kvCache)..where((t) => t.cacheKey.equals(key))).getSingleOrNull();

  Future<void> writeCache(String key, String payload, DateTime fetchedAtUtc) => into(kvCache)
      .insertOnConflictUpdate(
        KvCacheCompanion.insert(cacheKey: key, payload: payload, fetchedAtUtc: fetchedAtUtc),
      );

  Stream<List<String>> watchFavoriteIds() => (select(
    favorites,
  )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).map((r) => r.stationId).watch();

  Future<void> toggleFavorite(String stationId) => transaction(() async {
    final existing = await (select(
      favorites,
    )..where((t) => t.stationId.equals(stationId))).getSingleOrNull();
    if (existing != null) {
      await (delete(favorites)..where((t) => t.stationId.equals(stationId))).go();
      return;
    }
    final count = await favorites.count().getSingle();
    await into(favorites).insert(FavoritesCompanion.insert(stationId: stationId, sortOrder: count));
  });

  Future<String?> readSetting(String key) async => (await (select(
    settings,
  )..where((t) => t.settingKey.equals(key))).getSingleOrNull())?.settingValue;

  Future<void> writeSetting(String key, String value) =>
      into(settings)
          .insertOnConflictUpdate(SettingsCompanion.insert(settingKey: key, settingValue: value));
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

String? _blankToNull(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}
