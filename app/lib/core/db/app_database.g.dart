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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupNameMeta = const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [stationId, sortOrder, label, note, groupName];
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
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
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
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      ),
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

  /// User's own name for the place ("Hố sâu gốc si"), note, group (v2).
  final String? label;
  final String? note;
  final String? groupName;
  const Favorite({
    required this.stationId,
    required this.sortOrder,
    this.label,
    this.note,
    this.groupName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['station_id'] = Variable<String>(stationId);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      stationId: Value(stationId),
      sortOrder: Value(sortOrder),
      label: label == null && nullToAbsent ? const Value.absent() : Value(label),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      groupName: groupName == null && nullToAbsent ? const Value.absent() : Value(groupName),
    );
  }

  factory Favorite.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Favorite(
      stationId: serializer.fromJson<String>(json['stationId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      label: serializer.fromJson<String?>(json['label']),
      note: serializer.fromJson<String?>(json['note']),
      groupName: serializer.fromJson<String?>(json['groupName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stationId': serializer.toJson<String>(stationId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'label': serializer.toJson<String?>(label),
      'note': serializer.toJson<String?>(note),
      'groupName': serializer.toJson<String?>(groupName),
    };
  }

  Favorite copyWith({
    String? stationId,
    int? sortOrder,
    Value<String?> label = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> groupName = const Value.absent(),
  }) => Favorite(
    stationId: stationId ?? this.stationId,
    sortOrder: sortOrder ?? this.sortOrder,
    label: label.present ? label.value : this.label,
    note: note.present ? note.value : this.note,
    groupName: groupName.present ? groupName.value : this.groupName,
  );
  Favorite copyWithCompanion(FavoritesCompanion data) {
    return Favorite(
      stationId: data.stationId.present ? data.stationId.value : this.stationId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      label: data.label.present ? data.label.value : this.label,
      note: data.note.present ? data.note.value : this.note,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Favorite(')
          ..write('stationId: $stationId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('label: $label, ')
          ..write('note: $note, ')
          ..write('groupName: $groupName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(stationId, sortOrder, label, note, groupName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Favorite &&
          other.stationId == this.stationId &&
          other.sortOrder == this.sortOrder &&
          other.label == this.label &&
          other.note == this.note &&
          other.groupName == this.groupName);
}

class FavoritesCompanion extends UpdateCompanion<Favorite> {
  final Value<String> stationId;
  final Value<int> sortOrder;
  final Value<String?> label;
  final Value<String?> note;
  final Value<String?> groupName;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.stationId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.label = const Value.absent(),
    this.note = const Value.absent(),
    this.groupName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String stationId,
    required int sortOrder,
    this.label = const Value.absent(),
    this.note = const Value.absent(),
    this.groupName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : stationId = Value(stationId),
       sortOrder = Value(sortOrder);
  static Insertable<Favorite> custom({
    Expression<String>? stationId,
    Expression<int>? sortOrder,
    Expression<String>? label,
    Expression<String>? note,
    Expression<String>? groupName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stationId != null) 'station_id': stationId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (label != null) 'label': label,
      if (note != null) 'note': note,
      if (groupName != null) 'group_name': groupName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? stationId,
    Value<int>? sortOrder,
    Value<String?>? label,
    Value<String?>? note,
    Value<String?>? groupName,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      stationId: stationId ?? this.stationId,
      sortOrder: sortOrder ?? this.sortOrder,
      label: label ?? this.label,
      note: note ?? this.note,
      groupName: groupName ?? this.groupName,
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
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
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
          ..write('label: $label, ')
          ..write('note: $note, ')
          ..write('groupName: $groupName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatchesTable extends Catches with TableInfo<$CatchesTable, CatchEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _placeIdMeta = const VerificationMeta('placeId');
  @override
  late final GeneratedColumn<String> placeId = GeneratedColumn<String>(
    'place_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeNameMeta = const VerificationMeta('placeName');
  @override
  late final GeneratedColumn<String> placeName = GeneratedColumn<String>(
    'place_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caughtAtUtcMeta = const VerificationMeta('caughtAtUtc');
  @override
  late final GeneratedColumn<DateTime> caughtAtUtc = GeneratedColumn<DateTime>(
    'caught_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta('species');
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthCmMeta = const VerificationMeta('lengthCm');
  @override
  late final GeneratedColumn<double> lengthCm = GeneratedColumn<double>(
    'length_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baitMeta = const VerificationMeta('bait');
  @override
  late final GeneratedColumn<String> bait = GeneratedColumn<String>(
    'bait',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<Uint8List> photo = GeneratedColumn<Uint8List>(
    'photo',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelCmMeta = const VerificationMeta('levelCm');
  @override
  late final GeneratedColumn<double> levelCm = GeneratedColumn<double>(
    'level_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waterStateMeta = const VerificationMeta('waterState');
  @override
  late final GeneratedColumn<String> waterState = GeneratedColumn<String>(
    'water_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureCMeta = const VerificationMeta('temperatureC');
  @override
  late final GeneratedColumn<double> temperatureC = GeneratedColumn<double>(
    'temperature_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _windKmhMeta = const VerificationMeta('windKmh');
  @override
  late final GeneratedColumn<double> windKmh = GeneratedColumn<double>(
    'wind_kmh',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _moonPhaseMeta = const VerificationMeta('moonPhase');
  @override
  late final GeneratedColumn<double> moonPhase = GeneratedColumn<double>(
    'moon_phase',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fishingScoreMeta = const VerificationMeta('fishingScore');
  @override
  late final GeneratedColumn<double> fishingScore = GeneratedColumn<double>(
    'fishing_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    placeId,
    placeName,
    lat,
    lon,
    caughtAtUtc,
    species,
    weightKg,
    lengthCm,
    bait,
    note,
    photo,
    levelCm,
    waterState,
    temperatureC,
    windKmh,
    moonPhase,
    fishingScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catches';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatchEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('place_id')) {
      context.handle(_placeIdMeta, placeId.isAcceptableOrUnknown(data['place_id']!, _placeIdMeta));
    } else if (isInserting) {
      context.missing(_placeIdMeta);
    }
    if (data.containsKey('place_name')) {
      context.handle(
        _placeNameMeta,
        placeName.isAcceptableOrUnknown(data['place_name']!, _placeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_placeNameMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(_latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(_lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('caught_at_utc')) {
      context.handle(
        _caughtAtUtcMeta,
        caughtAtUtc.isAcceptableOrUnknown(data['caught_at_utc']!, _caughtAtUtcMeta),
      );
    } else if (isInserting) {
      context.missing(_caughtAtUtcMeta);
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta, species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('length_cm')) {
      context.handle(
        _lengthCmMeta,
        lengthCm.isAcceptableOrUnknown(data['length_cm']!, _lengthCmMeta),
      );
    }
    if (data.containsKey('bait')) {
      context.handle(_baitMeta, bait.isAcceptableOrUnknown(data['bait']!, _baitMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('photo')) {
      context.handle(_photoMeta, photo.isAcceptableOrUnknown(data['photo']!, _photoMeta));
    }
    if (data.containsKey('level_cm')) {
      context.handle(_levelCmMeta, levelCm.isAcceptableOrUnknown(data['level_cm']!, _levelCmMeta));
    }
    if (data.containsKey('water_state')) {
      context.handle(
        _waterStateMeta,
        waterState.isAcceptableOrUnknown(data['water_state']!, _waterStateMeta),
      );
    }
    if (data.containsKey('temperature_c')) {
      context.handle(
        _temperatureCMeta,
        temperatureC.isAcceptableOrUnknown(data['temperature_c']!, _temperatureCMeta),
      );
    }
    if (data.containsKey('wind_kmh')) {
      context.handle(_windKmhMeta, windKmh.isAcceptableOrUnknown(data['wind_kmh']!, _windKmhMeta));
    }
    if (data.containsKey('moon_phase')) {
      context.handle(
        _moonPhaseMeta,
        moonPhase.isAcceptableOrUnknown(data['moon_phase']!, _moonPhaseMeta),
      );
    }
    if (data.containsKey('fishing_score')) {
      context.handle(
        _fishingScoreMeta,
        fishingScore.isAcceptableOrUnknown(data['fishing_score']!, _fishingScoreMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatchEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatchEntry(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      placeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_id'],
      )!,
      placeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_name'],
      )!,
      lat: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
      caughtAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}caught_at_utc'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      lengthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_cm'],
      ),
      bait: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}bait']),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      photo: attachedDatabase.typeMapping.read(DriftSqlType.blob, data['${effectivePrefix}photo']),
      levelCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}level_cm'],
      ),
      waterState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}water_state'],
      ),
      temperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature_c'],
      ),
      windKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}wind_kmh'],
      ),
      moonPhase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}moon_phase'],
      ),
      fishingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fishing_score'],
      ),
    );
  }

  @override
  $CatchesTable createAlias(String alias) {
    return $CatchesTable(attachedDatabase, alias);
  }
}

class CatchEntry extends DataClass implements Insertable<CatchEntry> {
  final int id;
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

  /// Re-encoded JPEG (no EXIF / location metadata).
  final Uint8List? photo;
  final double? levelCm;

  /// TideState name at the time ("rising", "falling", …).
  final String? waterState;
  final double? temperatureC;
  final double? windKmh;

  /// Moon phase 0..1 (0 new, 0.5 full).
  final double? moonPhase;
  final double? fishingScore;
  const CatchEntry({
    required this.id,
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
    this.levelCm,
    this.waterState,
    this.temperatureC,
    this.windKmh,
    this.moonPhase,
    this.fishingScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['place_id'] = Variable<String>(placeId);
    map['place_name'] = Variable<String>(placeName);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['caught_at_utc'] = Variable<DateTime>(caughtAtUtc);
    map['species'] = Variable<String>(species);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || lengthCm != null) {
      map['length_cm'] = Variable<double>(lengthCm);
    }
    if (!nullToAbsent || bait != null) {
      map['bait'] = Variable<String>(bait);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<Uint8List>(photo);
    }
    if (!nullToAbsent || levelCm != null) {
      map['level_cm'] = Variable<double>(levelCm);
    }
    if (!nullToAbsent || waterState != null) {
      map['water_state'] = Variable<String>(waterState);
    }
    if (!nullToAbsent || temperatureC != null) {
      map['temperature_c'] = Variable<double>(temperatureC);
    }
    if (!nullToAbsent || windKmh != null) {
      map['wind_kmh'] = Variable<double>(windKmh);
    }
    if (!nullToAbsent || moonPhase != null) {
      map['moon_phase'] = Variable<double>(moonPhase);
    }
    if (!nullToAbsent || fishingScore != null) {
      map['fishing_score'] = Variable<double>(fishingScore);
    }
    return map;
  }

  CatchesCompanion toCompanion(bool nullToAbsent) {
    return CatchesCompanion(
      id: Value(id),
      placeId: Value(placeId),
      placeName: Value(placeName),
      lat: Value(lat),
      lon: Value(lon),
      caughtAtUtc: Value(caughtAtUtc),
      species: Value(species),
      weightKg: weightKg == null && nullToAbsent ? const Value.absent() : Value(weightKg),
      lengthCm: lengthCm == null && nullToAbsent ? const Value.absent() : Value(lengthCm),
      bait: bait == null && nullToAbsent ? const Value.absent() : Value(bait),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      photo: photo == null && nullToAbsent ? const Value.absent() : Value(photo),
      levelCm: levelCm == null && nullToAbsent ? const Value.absent() : Value(levelCm),
      waterState: waterState == null && nullToAbsent ? const Value.absent() : Value(waterState),
      temperatureC: temperatureC == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureC),
      windKmh: windKmh == null && nullToAbsent ? const Value.absent() : Value(windKmh),
      moonPhase: moonPhase == null && nullToAbsent ? const Value.absent() : Value(moonPhase),
      fishingScore: fishingScore == null && nullToAbsent
          ? const Value.absent()
          : Value(fishingScore),
    );
  }

  factory CatchEntry.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatchEntry(
      id: serializer.fromJson<int>(json['id']),
      placeId: serializer.fromJson<String>(json['placeId']),
      placeName: serializer.fromJson<String>(json['placeName']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      caughtAtUtc: serializer.fromJson<DateTime>(json['caughtAtUtc']),
      species: serializer.fromJson<String>(json['species']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      lengthCm: serializer.fromJson<double?>(json['lengthCm']),
      bait: serializer.fromJson<String?>(json['bait']),
      note: serializer.fromJson<String?>(json['note']),
      photo: serializer.fromJson<Uint8List?>(json['photo']),
      levelCm: serializer.fromJson<double?>(json['levelCm']),
      waterState: serializer.fromJson<String?>(json['waterState']),
      temperatureC: serializer.fromJson<double?>(json['temperatureC']),
      windKmh: serializer.fromJson<double?>(json['windKmh']),
      moonPhase: serializer.fromJson<double?>(json['moonPhase']),
      fishingScore: serializer.fromJson<double?>(json['fishingScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'placeId': serializer.toJson<String>(placeId),
      'placeName': serializer.toJson<String>(placeName),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'caughtAtUtc': serializer.toJson<DateTime>(caughtAtUtc),
      'species': serializer.toJson<String>(species),
      'weightKg': serializer.toJson<double?>(weightKg),
      'lengthCm': serializer.toJson<double?>(lengthCm),
      'bait': serializer.toJson<String?>(bait),
      'note': serializer.toJson<String?>(note),
      'photo': serializer.toJson<Uint8List?>(photo),
      'levelCm': serializer.toJson<double?>(levelCm),
      'waterState': serializer.toJson<String?>(waterState),
      'temperatureC': serializer.toJson<double?>(temperatureC),
      'windKmh': serializer.toJson<double?>(windKmh),
      'moonPhase': serializer.toJson<double?>(moonPhase),
      'fishingScore': serializer.toJson<double?>(fishingScore),
    };
  }

  CatchEntry copyWith({
    int? id,
    String? placeId,
    String? placeName,
    double? lat,
    double? lon,
    DateTime? caughtAtUtc,
    String? species,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> lengthCm = const Value.absent(),
    Value<String?> bait = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<Uint8List?> photo = const Value.absent(),
    Value<double?> levelCm = const Value.absent(),
    Value<String?> waterState = const Value.absent(),
    Value<double?> temperatureC = const Value.absent(),
    Value<double?> windKmh = const Value.absent(),
    Value<double?> moonPhase = const Value.absent(),
    Value<double?> fishingScore = const Value.absent(),
  }) => CatchEntry(
    id: id ?? this.id,
    placeId: placeId ?? this.placeId,
    placeName: placeName ?? this.placeName,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    caughtAtUtc: caughtAtUtc ?? this.caughtAtUtc,
    species: species ?? this.species,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    lengthCm: lengthCm.present ? lengthCm.value : this.lengthCm,
    bait: bait.present ? bait.value : this.bait,
    note: note.present ? note.value : this.note,
    photo: photo.present ? photo.value : this.photo,
    levelCm: levelCm.present ? levelCm.value : this.levelCm,
    waterState: waterState.present ? waterState.value : this.waterState,
    temperatureC: temperatureC.present ? temperatureC.value : this.temperatureC,
    windKmh: windKmh.present ? windKmh.value : this.windKmh,
    moonPhase: moonPhase.present ? moonPhase.value : this.moonPhase,
    fishingScore: fishingScore.present ? fishingScore.value : this.fishingScore,
  );
  CatchEntry copyWithCompanion(CatchesCompanion data) {
    return CatchEntry(
      id: data.id.present ? data.id.value : this.id,
      placeId: data.placeId.present ? data.placeId.value : this.placeId,
      placeName: data.placeName.present ? data.placeName.value : this.placeName,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      caughtAtUtc: data.caughtAtUtc.present ? data.caughtAtUtc.value : this.caughtAtUtc,
      species: data.species.present ? data.species.value : this.species,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      lengthCm: data.lengthCm.present ? data.lengthCm.value : this.lengthCm,
      bait: data.bait.present ? data.bait.value : this.bait,
      note: data.note.present ? data.note.value : this.note,
      photo: data.photo.present ? data.photo.value : this.photo,
      levelCm: data.levelCm.present ? data.levelCm.value : this.levelCm,
      waterState: data.waterState.present ? data.waterState.value : this.waterState,
      temperatureC: data.temperatureC.present ? data.temperatureC.value : this.temperatureC,
      windKmh: data.windKmh.present ? data.windKmh.value : this.windKmh,
      moonPhase: data.moonPhase.present ? data.moonPhase.value : this.moonPhase,
      fishingScore: data.fishingScore.present ? data.fishingScore.value : this.fishingScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatchEntry(')
          ..write('id: $id, ')
          ..write('placeId: $placeId, ')
          ..write('placeName: $placeName, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('caughtAtUtc: $caughtAtUtc, ')
          ..write('species: $species, ')
          ..write('weightKg: $weightKg, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('bait: $bait, ')
          ..write('note: $note, ')
          ..write('photo: $photo, ')
          ..write('levelCm: $levelCm, ')
          ..write('waterState: $waterState, ')
          ..write('temperatureC: $temperatureC, ')
          ..write('windKmh: $windKmh, ')
          ..write('moonPhase: $moonPhase, ')
          ..write('fishingScore: $fishingScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    placeId,
    placeName,
    lat,
    lon,
    caughtAtUtc,
    species,
    weightKg,
    lengthCm,
    bait,
    note,
    $driftBlobEquality.hash(photo),
    levelCm,
    waterState,
    temperatureC,
    windKmh,
    moonPhase,
    fishingScore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatchEntry &&
          other.id == this.id &&
          other.placeId == this.placeId &&
          other.placeName == this.placeName &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.caughtAtUtc == this.caughtAtUtc &&
          other.species == this.species &&
          other.weightKg == this.weightKg &&
          other.lengthCm == this.lengthCm &&
          other.bait == this.bait &&
          other.note == this.note &&
          $driftBlobEquality.equals(other.photo, this.photo) &&
          other.levelCm == this.levelCm &&
          other.waterState == this.waterState &&
          other.temperatureC == this.temperatureC &&
          other.windKmh == this.windKmh &&
          other.moonPhase == this.moonPhase &&
          other.fishingScore == this.fishingScore);
}

class CatchesCompanion extends UpdateCompanion<CatchEntry> {
  final Value<int> id;
  final Value<String> placeId;
  final Value<String> placeName;
  final Value<double> lat;
  final Value<double> lon;
  final Value<DateTime> caughtAtUtc;
  final Value<String> species;
  final Value<double?> weightKg;
  final Value<double?> lengthCm;
  final Value<String?> bait;
  final Value<String?> note;
  final Value<Uint8List?> photo;
  final Value<double?> levelCm;
  final Value<String?> waterState;
  final Value<double?> temperatureC;
  final Value<double?> windKmh;
  final Value<double?> moonPhase;
  final Value<double?> fishingScore;
  const CatchesCompanion({
    this.id = const Value.absent(),
    this.placeId = const Value.absent(),
    this.placeName = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.caughtAtUtc = const Value.absent(),
    this.species = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.lengthCm = const Value.absent(),
    this.bait = const Value.absent(),
    this.note = const Value.absent(),
    this.photo = const Value.absent(),
    this.levelCm = const Value.absent(),
    this.waterState = const Value.absent(),
    this.temperatureC = const Value.absent(),
    this.windKmh = const Value.absent(),
    this.moonPhase = const Value.absent(),
    this.fishingScore = const Value.absent(),
  });
  CatchesCompanion.insert({
    this.id = const Value.absent(),
    required String placeId,
    required String placeName,
    required double lat,
    required double lon,
    required DateTime caughtAtUtc,
    required String species,
    this.weightKg = const Value.absent(),
    this.lengthCm = const Value.absent(),
    this.bait = const Value.absent(),
    this.note = const Value.absent(),
    this.photo = const Value.absent(),
    this.levelCm = const Value.absent(),
    this.waterState = const Value.absent(),
    this.temperatureC = const Value.absent(),
    this.windKmh = const Value.absent(),
    this.moonPhase = const Value.absent(),
    this.fishingScore = const Value.absent(),
  }) : placeId = Value(placeId),
       placeName = Value(placeName),
       lat = Value(lat),
       lon = Value(lon),
       caughtAtUtc = Value(caughtAtUtc),
       species = Value(species);
  static Insertable<CatchEntry> custom({
    Expression<int>? id,
    Expression<String>? placeId,
    Expression<String>? placeName,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<DateTime>? caughtAtUtc,
    Expression<String>? species,
    Expression<double>? weightKg,
    Expression<double>? lengthCm,
    Expression<String>? bait,
    Expression<String>? note,
    Expression<Uint8List>? photo,
    Expression<double>? levelCm,
    Expression<String>? waterState,
    Expression<double>? temperatureC,
    Expression<double>? windKmh,
    Expression<double>? moonPhase,
    Expression<double>? fishingScore,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (placeId != null) 'place_id': placeId,
      if (placeName != null) 'place_name': placeName,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (caughtAtUtc != null) 'caught_at_utc': caughtAtUtc,
      if (species != null) 'species': species,
      if (weightKg != null) 'weight_kg': weightKg,
      if (lengthCm != null) 'length_cm': lengthCm,
      if (bait != null) 'bait': bait,
      if (note != null) 'note': note,
      if (photo != null) 'photo': photo,
      if (levelCm != null) 'level_cm': levelCm,
      if (waterState != null) 'water_state': waterState,
      if (temperatureC != null) 'temperature_c': temperatureC,
      if (windKmh != null) 'wind_kmh': windKmh,
      if (moonPhase != null) 'moon_phase': moonPhase,
      if (fishingScore != null) 'fishing_score': fishingScore,
    });
  }

  CatchesCompanion copyWith({
    Value<int>? id,
    Value<String>? placeId,
    Value<String>? placeName,
    Value<double>? lat,
    Value<double>? lon,
    Value<DateTime>? caughtAtUtc,
    Value<String>? species,
    Value<double?>? weightKg,
    Value<double?>? lengthCm,
    Value<String?>? bait,
    Value<String?>? note,
    Value<Uint8List?>? photo,
    Value<double?>? levelCm,
    Value<String?>? waterState,
    Value<double?>? temperatureC,
    Value<double?>? windKmh,
    Value<double?>? moonPhase,
    Value<double?>? fishingScore,
  }) {
    return CatchesCompanion(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      caughtAtUtc: caughtAtUtc ?? this.caughtAtUtc,
      species: species ?? this.species,
      weightKg: weightKg ?? this.weightKg,
      lengthCm: lengthCm ?? this.lengthCm,
      bait: bait ?? this.bait,
      note: note ?? this.note,
      photo: photo ?? this.photo,
      levelCm: levelCm ?? this.levelCm,
      waterState: waterState ?? this.waterState,
      temperatureC: temperatureC ?? this.temperatureC,
      windKmh: windKmh ?? this.windKmh,
      moonPhase: moonPhase ?? this.moonPhase,
      fishingScore: fishingScore ?? this.fishingScore,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (placeId.present) {
      map['place_id'] = Variable<String>(placeId.value);
    }
    if (placeName.present) {
      map['place_name'] = Variable<String>(placeName.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (caughtAtUtc.present) {
      map['caught_at_utc'] = Variable<DateTime>(caughtAtUtc.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (lengthCm.present) {
      map['length_cm'] = Variable<double>(lengthCm.value);
    }
    if (bait.present) {
      map['bait'] = Variable<String>(bait.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (photo.present) {
      map['photo'] = Variable<Uint8List>(photo.value);
    }
    if (levelCm.present) {
      map['level_cm'] = Variable<double>(levelCm.value);
    }
    if (waterState.present) {
      map['water_state'] = Variable<String>(waterState.value);
    }
    if (temperatureC.present) {
      map['temperature_c'] = Variable<double>(temperatureC.value);
    }
    if (windKmh.present) {
      map['wind_kmh'] = Variable<double>(windKmh.value);
    }
    if (moonPhase.present) {
      map['moon_phase'] = Variable<double>(moonPhase.value);
    }
    if (fishingScore.present) {
      map['fishing_score'] = Variable<double>(fishingScore.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatchesCompanion(')
          ..write('id: $id, ')
          ..write('placeId: $placeId, ')
          ..write('placeName: $placeName, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('caughtAtUtc: $caughtAtUtc, ')
          ..write('species: $species, ')
          ..write('weightKg: $weightKg, ')
          ..write('lengthCm: $lengthCm, ')
          ..write('bait: $bait, ')
          ..write('note: $note, ')
          ..write('photo: $photo, ')
          ..write('levelCm: $levelCm, ')
          ..write('waterState: $waterState, ')
          ..write('temperatureC: $temperatureC, ')
          ..write('windKmh: $windKmh, ')
          ..write('moonPhase: $moonPhase, ')
          ..write('fishingScore: $fishingScore')
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
  late final $CatchesTable catches = $CatchesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [kvCache, favorites, catches, settings];
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
  Value<String?> label,
  Value<String?> note,
  Value<String?> groupName,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> stationId,
  Value<int> sortOrder,
  Value<String?> label,
  Value<String?> note,
  Value<String?> groupName,
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

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);
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
          updateCompanionCallback:
              ({
                Value<String> stationId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                stationId: stationId,
                sortOrder: sortOrder,
                label: label,
                note: note,
                groupName: groupName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stationId,
                required int sortOrder,
                Value<String?> label = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> groupName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                stationId: stationId,
                sortOrder: sortOrder,
                label: label,
                note: note,
                groupName: groupName,
                rowid: rowid,
              ),
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
typedef $$CatchesTableCreateCompanionBuilder = CatchesCompanion Function({
  Value<int> id,
  required String placeId,
  required String placeName,
  required double lat,
  required double lon,
  required DateTime caughtAtUtc,
  required String species,
  Value<double?> weightKg,
  Value<double?> lengthCm,
  Value<String?> bait,
  Value<String?> note,
  Value<Uint8List?> photo,
  Value<double?> levelCm,
  Value<String?> waterState,
  Value<double?> temperatureC,
  Value<double?> windKmh,
  Value<double?> moonPhase,
  Value<double?> fishingScore,
});
typedef $$CatchesTableUpdateCompanionBuilder = CatchesCompanion Function({
  Value<int> id,
  Value<String> placeId,
  Value<String> placeName,
  Value<double> lat,
  Value<double> lon,
  Value<DateTime> caughtAtUtc,
  Value<String> species,
  Value<double?> weightKg,
  Value<double?> lengthCm,
  Value<String?> bait,
  Value<String?> note,
  Value<Uint8List?> photo,
  Value<double?> levelCm,
  Value<String?> waterState,
  Value<double?> temperatureC,
  Value<double?> windKmh,
  Value<double?> moonPhase,
  Value<double?> fishingScore,
});

class $$CatchesTableFilterComposer extends Composer<_$AppDatabase, $CatchesTable> {
  $$CatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placeId =>
      $composableBuilder(column: $table.placeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get caughtAtUtc =>
      $composableBuilder(column: $table.caughtAtUtc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lengthCm =>
      $composableBuilder(column: $table.lengthCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bait =>
      $composableBuilder(column: $table.bait, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get levelCm =>
      $composableBuilder(column: $table.levelCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get waterState =>
      $composableBuilder(column: $table.waterState, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get temperatureC =>
      $composableBuilder(column: $table.temperatureC, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get windKmh =>
      $composableBuilder(column: $table.windKmh, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get moonPhase =>
      $composableBuilder(column: $table.moonPhase, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fishingScore =>
      $composableBuilder(column: $table.fishingScore, builder: (column) => ColumnFilters(column));
}

class $$CatchesTableOrderingComposer extends Composer<_$AppDatabase, $CatchesTable> {
  $$CatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeId =>
      $composableBuilder(column: $table.placeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get caughtAtUtc =>
      $composableBuilder(column: $table.caughtAtUtc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lengthCm =>
      $composableBuilder(column: $table.lengthCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bait =>
      $composableBuilder(column: $table.bait, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get levelCm =>
      $composableBuilder(column: $table.levelCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get waterState =>
      $composableBuilder(column: $table.waterState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get temperatureC =>
      $composableBuilder(column: $table.temperatureC, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get windKmh =>
      $composableBuilder(column: $table.windKmh, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get moonPhase =>
      $composableBuilder(column: $table.moonPhase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fishingScore =>
      $composableBuilder(column: $table.fishingScore, builder: (column) => ColumnOrderings(column));
}

class $$CatchesTableAnnotationComposer extends Composer<_$AppDatabase, $CatchesTable> {
  $$CatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get placeId =>
      $composableBuilder(column: $table.placeId, builder: (column) => column);

  GeneratedColumn<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<DateTime> get caughtAtUtc =>
      $composableBuilder(column: $table.caughtAtUtc, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get lengthCm =>
      $composableBuilder(column: $table.lengthCm, builder: (column) => column);

  GeneratedColumn<String> get bait =>
      $composableBuilder(column: $table.bait, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<Uint8List> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<double> get levelCm =>
      $composableBuilder(column: $table.levelCm, builder: (column) => column);

  GeneratedColumn<String> get waterState =>
      $composableBuilder(column: $table.waterState, builder: (column) => column);

  GeneratedColumn<double> get temperatureC =>
      $composableBuilder(column: $table.temperatureC, builder: (column) => column);

  GeneratedColumn<double> get windKmh =>
      $composableBuilder(column: $table.windKmh, builder: (column) => column);

  GeneratedColumn<double> get moonPhase =>
      $composableBuilder(column: $table.moonPhase, builder: (column) => column);

  GeneratedColumn<double> get fishingScore =>
      $composableBuilder(column: $table.fishingScore, builder: (column) => column);
}

class $$CatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatchesTable,
          CatchEntry,
          $$CatchesTableFilterComposer,
          $$CatchesTableOrderingComposer,
          $$CatchesTableAnnotationComposer,
          $$CatchesTableCreateCompanionBuilder,
          $$CatchesTableUpdateCompanionBuilder,
          (CatchEntry, BaseReferences<_$AppDatabase, $CatchesTable, CatchEntry>),
          CatchEntry,
          PrefetchHooks Function()
        > {
  $$CatchesTableTableManager(_$AppDatabase db, $CatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> placeId = const Value.absent(),
                Value<String> placeName = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<DateTime> caughtAtUtc = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> lengthCm = const Value.absent(),
                Value<String?> bait = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<Uint8List?> photo = const Value.absent(),
                Value<double?> levelCm = const Value.absent(),
                Value<String?> waterState = const Value.absent(),
                Value<double?> temperatureC = const Value.absent(),
                Value<double?> windKmh = const Value.absent(),
                Value<double?> moonPhase = const Value.absent(),
                Value<double?> fishingScore = const Value.absent(),
              }) => CatchesCompanion(
                id: id,
                placeId: placeId,
                placeName: placeName,
                lat: lat,
                lon: lon,
                caughtAtUtc: caughtAtUtc,
                species: species,
                weightKg: weightKg,
                lengthCm: lengthCm,
                bait: bait,
                note: note,
                photo: photo,
                levelCm: levelCm,
                waterState: waterState,
                temperatureC: temperatureC,
                windKmh: windKmh,
                moonPhase: moonPhase,
                fishingScore: fishingScore,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String placeId,
                required String placeName,
                required double lat,
                required double lon,
                required DateTime caughtAtUtc,
                required String species,
                Value<double?> weightKg = const Value.absent(),
                Value<double?> lengthCm = const Value.absent(),
                Value<String?> bait = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<Uint8List?> photo = const Value.absent(),
                Value<double?> levelCm = const Value.absent(),
                Value<String?> waterState = const Value.absent(),
                Value<double?> temperatureC = const Value.absent(),
                Value<double?> windKmh = const Value.absent(),
                Value<double?> moonPhase = const Value.absent(),
                Value<double?> fishingScore = const Value.absent(),
              }) => CatchesCompanion.insert(
                id: id,
                placeId: placeId,
                placeName: placeName,
                lat: lat,
                lon: lon,
                caughtAtUtc: caughtAtUtc,
                species: species,
                weightKg: weightKg,
                lengthCm: lengthCm,
                bait: bait,
                note: note,
                photo: photo,
                levelCm: levelCm,
                waterState: waterState,
                temperatureC: temperatureC,
                windKmh: windKmh,
                moonPhase: moonPhase,
                fishingScore: fishingScore,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CatchesTable, CatchEntry>(table),
                  BaseReferences<_$AppDatabase, $CatchesTable, CatchEntry>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatchesTable,
      CatchEntry,
      $$CatchesTableFilterComposer,
      $$CatchesTableOrderingComposer,
      $$CatchesTableAnnotationComposer,
      $$CatchesTableCreateCompanionBuilder,
      $$CatchesTableUpdateCompanionBuilder,
      (CatchEntry, BaseReferences<_$AppDatabase, $CatchesTable, CatchEntry>),
      CatchEntry,
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
  $$CatchesTableTableManager get catches => $$CatchesTableTableManager(_db, _db.catches);
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
