// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Station _$StationFromJson(Map<String, dynamic> json) => _Station(
  id: json['id'] as String,
  name: json['name'] as String,
  region: json['region'] as String,
  lat: (json['lat'] as num).toDouble(),
  lon: (json['lon'] as num).toDouble(),
  kind: $enumDecode(_$StationKindEnumMap, json['kind']),
  coordApprox: json['coord_approx'] as bool? ?? false,
  iocCode: json['ioc_code'] as String?,
  iocSensor: json['ioc_sensor'] as String?,
  tideAsset: json['tide_asset'] as String?,
  river: json['river'] as String?,
  kttvKey: json['kttv_key'] as String?,
  tidal: json['tidal'] as bool? ?? false,
  seaRefLat: (json['sea_ref_lat'] as num?)?.toDouble(),
  seaRefLon: (json['sea_ref_lon'] as num?)?.toDouble(),
);

Map<String, dynamic> _$StationToJson(_Station instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'region': instance.region,
  'lat': instance.lat,
  'lon': instance.lon,
  'kind': _$StationKindEnumMap[instance.kind]!,
  'coord_approx': instance.coordApprox,
  'ioc_code': instance.iocCode,
  'ioc_sensor': instance.iocSensor,
  'tide_asset': instance.tideAsset,
  'river': instance.river,
  'kttv_key': instance.kttvKey,
  'tidal': instance.tidal,
  'sea_ref_lat': instance.seaRefLat,
  'sea_ref_lon': instance.seaRefLon,
};

const _$StationKindEnumMap = {
  StationKind.gauge: 'gauge',
  StationKind.model: 'model',
  StationKind.river: 'river',
  StationKind.riverDaily: 'river_daily',
};
