// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $KvCacheTable extends KvCache with TableInfo<$KvCacheTable, KvCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta('cacheKey');
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtUtcMeta = const VerificationMeta('fetchedAtUtc');
  @override
  late final GeneratedColumn<DateTime> fetchedAtUtc = GeneratedColumn<DateTime>(
    'fetched_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cacheKey, payload, fetchedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('fetched_at_utc')) {
      context.handle(
        _fetchedAtUtcMeta,
        fetchedAtUtc.isAcceptableOrUnknown(data['fetched_at_utc']!, _fetchedAtUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  KvCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvCacheData(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      fetchedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at_utc'],
      )!,
    );
  }

  @override
  $KvCacheTable createAlias(String alias) {
    return $KvCacheTable(attachedDatabase, alias);
  }
}

class KvCacheData extends DataClass implements Insertable<KvCacheData> {
  final String cacheKey;
  final String payload;
  final DateTime fetchedAtUtc;
  const KvCacheData({required this.cacheKey, required this.payload, required this.fetchedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['payload'] = Variable<String>(payload);
    map['fetched_at_utc'] = Variable<DateTime>(fetchedAtUtc);
    return map;
  }

  KvCacheCompanion toCompanion(bool nullToAbsent) {
    return KvCacheCompanion(
      cacheKey: Value(cacheKey),
      payload: Value(payload),
      fetchedAtUtc: Value(fetchedAtUtc),
    );
  }

  factory KvCacheData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvCacheData(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      payload: serializer.fromJson<String>(json['payload']),
      fetchedAtUtc: serializer.fromJson<DateTime>(json['fetchedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'payload': serializer.toJson<String>(payload),
      'fetchedAtUtc': serializer.toJson<DateTime>(fetchedAtUtc),
    };
  }

  KvCacheData copyWith({String? cacheKey, String? payload, DateTime? fetchedAtUtc}) => KvCacheData(
    cacheKey: cacheKey ?? this.cacheKey,
    payload: payload ?? this.payload,
    fetchedAtUtc: fetchedAtUtc ?? this.fetchedAtUtc,
  );
  KvCacheData copyWithCompanion(KvCacheCompanion data) {
    return KvCacheData(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      payload: data.payload.present ? data.payload.value : this.payload,
      fetchedAtUtc: data.fetchedAtUtc.present ? data.fetchedAtUtc.value : this.fetchedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvCacheData(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payload: $payload, ')
          ..write('fetchedAtUtc: $fetchedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, payload, fetchedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvCacheData &&
          other.cacheKey == this.cacheKey &&
          other.payload == this.payload &&
          other.fetchedAtUtc == this.fetchedAtUtc);
}

class KvCacheCompanion extends UpdateCompanion<KvCacheData> {
  final Value<String> cacheKey;
  final Value<String> payload;
  final Value<DateTime> fetchedAtUtc;
  final Value<int> rowid;
  const KvCacheCompanion({
    this.cacheKey = const Value.absent(),
    this.payload = const Value.absent(),
    this.fetchedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvCacheCompanion.insert({
    required String cacheKey,
    required String payload,
    required DateTime fetchedAtUtc,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       payload = Value(payload),
       fetchedAtUtc = Value(fetchedAtUtc);
  static Insertable<KvCacheData> custom({
    Expression<String>? cacheKey,
    Expression<String>? payload,
    Expression<DateTime>? fetchedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (payload != null) 'payload': payload,
      if (fetchedAtUtc != null) 'fetched_at_utc': fetchedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvCacheCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? payload,
    Value<DateTime>? fetchedAtUtc,
    Value<int>? rowid,
  }) {
    return KvCacheCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      payload: payload ?? this.payload,
      fetchedAtUtc: fetchedAtUtc ?? this.fetchedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (fetchedAtUtc.present) {
      map['fetched_at_utc'] = Variable<DateTime>(fetchedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvCacheCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('payload: $payload, ')
          ..write('fetchedAtUtc: $fetchedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites with TableInfo<$FavoritesTable, Favorite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stationIdMeta = const VerificationMeta('stationId');
  @override
  late final GeneratedColumn<String> stationId = GeneratedColumn<String>(
    'station_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [stationId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(Insertable<Favorite> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('station_id')) {
      context.handle(
        _stationIdMeta,
        stationId.isAcceptableOrUnknown(data['station_id']!, _stationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stationIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stationId};
  @override
  Favorite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Favorite(
      stationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class Favorite extends DataClass implements Insertable<Favorite> {
  final String stationId;
  final int sortOrder;
  const Favorite({required this.stationId, required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['station_id'] = Variable<String>(stationId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(stationId: Value(stationId), sortOrder: Value(sortOrder));
  }

  factory Favorite.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      stationId: serializer.fromJson<String>(json['stationId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stationId': serializer.toJson<String>(stationId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Favorite copyWith({String? stationId, int? sortOrder}) =>
      Favorite(stationId: stationId ?? this.stationId, sortOrder: sortOrder ?? this.sortOrder);
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      stationId: data.stationId.present ? data.stationId.value : this.stationId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('stationId: $stationId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(stationId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite && other.stationId == this.stationId && other.sortOrder == this.sortOrder);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> stationId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.stationId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String stationId,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : stationId = Value(stationId),
       sortOrder = Value(sortOrder);
  static Insertable<Favorite> custom({
    Expression<String>? stationId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stationId != null) 'station_id': stationId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? stationId,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      stationId: stationId ?? this.stationId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stationId.present) {
      map['station_id'] = Variable<String>(stationId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('stationId: $stationId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta = const VerificationMeta('settingKey');
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingValueMeta = const VerificationMeta('settingValue');
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
    'setting_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [settingKey, settingValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
        _settingValueMeta,
        settingValue.isAcceptableOrUnknown(data['setting_value']!, _settingValueMeta),
      );
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      settingValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String settingKey;
  final String settingValue;
  const Setting({required this.settingKey, required this.settingValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(settingKey: Value(settingKey), settingValue: Value(settingValue));
  }

  factory Setting.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
    };
  }

  Setting copyWith({String? settingKey, String? settingValue}) => Setting(
    settingKey: settingKey ?? this.settingKey,
    settingValue: settingValue ?? this.settingValue,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      settingKey: data.settingKey.present ? data.settingKey.value : this.settingKey,
      settingValue: data.settingValue.present ? data.settingValue.value : this.settingValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, settingValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<int> rowid;
  const SettingsCompanion({
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String settingKey,
    required String settingValue,
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       settingValue = Value(settingValue);
  static Insertable<Setting> custom({
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? settingValue,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $KvCacheTable kvCache = $KvCacheTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [kvCache, favorites, settings];
}

typedef $$KvCacheTableCreateCompanionBuilder = KvCacheCompanion Function({
  required String cacheKey,
  required String payload,
  required DateTime fetchedAtUtc,
  Value<int> rowid,
});
typedef $$KvCacheTableUpdateCompanionBuilder = KvCacheCompanion Function({
  Value<String> cacheKey,
  Value<String> payload,
  Value<DateTime> fetchedAtUtc,
  Value<int> rowid,
});

class $$KvCacheTableFilterComposer extends Composer<_$AppDatabase, $KvCacheTable> {
  $$KvCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAtUtc =>
      $composableBuilder(column: $table.fetchedAtUtc, builder: (column) => ColumnFilters(column));
}

class $$KvCacheTableOrderingComposer extends Composer<_$AppDatabase, $KvCacheTable> {
  $$KvCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAtUtc =>
      $composableBuilder(column: $table.fetchedAtUtc, builder: (column) => ColumnOrderings(column));
}

class $$KvCacheTableAnnotationComposer extends Composer<_$AppDatabase, $KvCacheTable> {
  $$KvCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAtUtc =>
      $composableBuilder(column: $table.fetchedAtUtc, builder: (column) => column);
}

class $$KvCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KvCacheTable,
          KvCacheData,
          $$KvCacheTableFilterComposer,
          $$KvCacheTableOrderingComposer,
          $$KvCacheTableAnnotationComposer,
          $$KvCacheTableCreateCompanionBuilder,
          $$KvCacheTableUpdateCompanionBuilder,
          (KvCacheData, BaseReferences<_$AppDatabase, $KvCacheTable, KvCacheData>),
          KvCacheData,
          PrefetchHooks Function()
        > {
  $$KvCacheTableTableManager(_$AppDatabase db, $KvCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$KvCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KvCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KvCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> fetchedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KvCacheCompanion(
                cacheKey: cacheKey,
                payload: payload,
                fetchedAtUtc: fetchedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String payload,
                required DateTime fetchedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => KvCacheCompanion.insert(
                cacheKey: cacheKey,
                payload: payload,
                fetchedAtUtc: fetchedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KvCacheTable, KvCacheData>(table),
                  BaseReferences<_$AppDatabase, $KvCacheTable, KvCacheData>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KvCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KvCacheTable,
      KvCacheData,
      $$KvCacheTableFilterComposer,
      $$KvCacheTableOrderingComposer,
      $$KvCacheTableAnnotationComposer,
      $$KvCacheTableCreateCompanionBuilder,
      $$KvCacheTableUpdateCompanionBuilder,
      (KvCacheData, BaseReferences<_$AppDatabase, $KvCacheTable, KvCacheData>),
      KvCacheData,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String stationId,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> stationId,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stationId =>
      $composableBuilder(column: $table.stationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$FavoritesTableOrderingComposer extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stationId =>
      $composableBuilder(column: $table.stationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$FavoritesTableAnnotationComposer extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stationId =>
      $composableBuilder(column: $table.stationId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          Favorite,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
          Favorite,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> stationId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => FavoritesCompanion(stationId: stationId, sortOrder: sortOrder, rowid: rowid),
          createCompanionCallback: ({
            required String stationId,
            required int sortOrder,
            Value<int> rowid = const Value.absent(),
          }) => FavoritesCompanion.insert(stationId: stationId, sortOrder: sortOrder, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FavoritesTable, Favorite>(table),
                  BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      Favorite,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (Favorite, BaseReferences<_$AppDatabase, $FavoritesTable, Favorite>),
      Favorite,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String settingKey,
  required String settingValue,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> settingKey,
  Value<String> settingValue,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey =>
      $composableBuilder(column: $table.settingKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingValue =>
      $composableBuilder(column: $table.settingValue, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey =>
      $composableBuilder(column: $table.settingKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingValue =>
      $composableBuilder(column: $table.settingValue, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey =>
      $composableBuilder(column: $table.settingKey, builder: (column) => column);

  GeneratedColumn<String> get settingValue =>
      $composableBuilder(column: $table.settingValue, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> settingKey = const Value.absent(),
            Value<String> settingValue = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(settingKey: settingKey, settingValue: settingValue, rowid: rowid),
          createCompanionCallback:
              ({
                required String settingKey,
                required String settingValue,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$KvCacheTableTableManager get kvCache => $$KvCacheTableTableManager(_db, _db.kvCache);
  $$FavoritesTableTableManager get favorites => $$FavoritesTableTableManager(_db, _db.favorites);
  $$SettingsTableTableManager get settings => $$SettingsTableTableManager(_db, _db.settings);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';
