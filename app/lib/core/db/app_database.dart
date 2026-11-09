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

  @override
  Set<Column<Object>> get primaryKey => {stationId};
}

/// Simple key/value settings.
class Settings extends Table {
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();

  @override
  Set<Column<Object>> get primaryKey => {settingKey};
}

@DriftDatabase(tables: [KvCache, Favorites, Settings])
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
  int get schemaVersion => 1;

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
