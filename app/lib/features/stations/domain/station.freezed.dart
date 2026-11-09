// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Station {

 String get id; String get name; String get region; double get lat; double get lon; StationKind get kind; bool get coordApprox; String? get iocCode; String? get iocSensor; String? get tideAsset;/// River name for river stations ("Hồng").
 String? get river;/// Station label as printed in the KTTV bulletin, spaces removed ("HàNội").
 String? get kttvKey;/// Water oscillates with the sea tide here (bulletin says "dao động theo triều").
 bool get tidal;/// Sea point whose tide drives this river reach (Open-Meteo Marine).
 double? get seaRefLat; double? get seaRefLon;
/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StationCopyWith<Station> get copyWith => _$StationCopyWithImpl<Station>(this as Station, _$identity);

  /// Serializes this Station to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Station;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Station&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lon, _this.lon) || other.lon == _this.lon)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.coordApprox, _this.coordApprox) || other.coordApprox == _this.coordApprox)&&(identical(other.iocCode, _this.iocCode) || other.iocCode == _this.iocCode)&&(identical(other.iocSensor, _this.iocSensor) || other.iocSensor == _this.iocSensor)&&(identical(other.tideAsset, _this.tideAsset) || other.tideAsset == _this.tideAsset)&&(identical(other.river, _this.river) || other.river == _this.river)&&(identical(other.kttvKey, _this.kttvKey) || other.kttvKey == _this.kttvKey)&&(identical(other.tidal, _this.tidal) || other.tidal == _this.tidal)&&(identical(other.seaRefLat, _this.seaRefLat) || other.seaRefLat == _this.seaRefLat)&&(identical(other.seaRefLon, _this.seaRefLon) || other.seaRefLon == _this.seaRefLon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Station;
  return Object.hash(runtimeType,_this.id,_this.name,_this.region,_this.lat,_this.lon,_this.kind,_this.coordApprox,_this.iocCode,_this.iocSensor,_this.tideAsset,_this.river,_this.kttvKey,_this.tidal,_this.seaRefLat,_this.seaRefLon);
}

@override
String toString() {
  final _this = this as Station;
  return 'Station(id: ${_this.id}, name: ${_this.name}, region: ${_this.region}, lat: ${_this.lat}, lon: ${_this.lon}, kind: ${_this.kind}, coordApprox: ${_this.coordApprox}, iocCode: ${_this.iocCode}, iocSensor: ${_this.iocSensor}, tideAsset: ${_this.tideAsset}, river: ${_this.river}, kttvKey: ${_this.kttvKey}, tidal: ${_this.tidal}, seaRefLat: ${_this.seaRefLat}, seaRefLon: ${_this.seaRefLon})';
}


}

/// @nodoc
abstract mixin class $StationCopyWith<$Res>  {
  factory $StationCopyWith(Station value, $Res Function(Station) _then) = _$StationCopyWithImpl;
@useResult
$Res call({
 String id, String name, String region, double lat, double lon, StationKind kind, bool coordApprox, String? iocCode, String? iocSensor, String? tideAsset, String? river, String? kttvKey, bool tidal, double? seaRefLat, double? seaRefLon
});




}
/// @nodoc
class _$StationCopyWithImpl<$Res>
    implements $StationCopyWith<$Res> {
  _$StationCopyWithImpl(this._self, this._then);

  final Station _self;
  final $Res Function(Station) _then;

/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? region = null,Object? lat = null,Object? lon = null,Object? kind = null,Object? coordApprox = null,Object? iocCode = freezed,Object? iocSensor = freezed,Object? tideAsset = freezed,Object? river = freezed,Object? kttvKey = freezed,Object? tidal = null,Object? seaRefLat = freezed,Object? seaRefLon = freezed,}) {
  return _then(Station(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as StationKind,coordApprox: null == coordApprox ? _self.coordApprox : coordApprox // ignore: cast_nullable_to_non_nullable
as bool,iocCode: freezed == iocCode ? _self.iocCode : iocCode // ignore: cast_nullable_to_non_nullable
as String?,iocSensor: freezed == iocSensor ? _self.iocSensor : iocSensor // ignore: cast_nullable_to_non_nullable
as String?,tideAsset: freezed == tideAsset ? _self.tideAsset : tideAsset // ignore: cast_nullable_to_non_nullable
as String?,river: freezed == river ? _self.river : river // ignore: cast_nullable_to_non_nullable
as String?,kttvKey: freezed == kttvKey ? _self.kttvKey : kttvKey // ignore: cast_nullable_to_non_nullable
as String?,tidal: null == tidal ? _self.tidal : tidal // ignore: cast_nullable_to_non_nullable
as bool,seaRefLat: freezed == seaRefLat ? _self.seaRefLat : seaRefLat // ignore: cast_nullable_to_non_nullable
as double?,seaRefLon: freezed == seaRefLon ? _self.seaRefLon : seaRefLon // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Station].
extension StationPatterns on Station {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Station value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Station() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Station value)  $default,){
final _that = this;
switch (_that) {
case _Station():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Station value)?  $default,){
final _that = this;
switch (_that) {
case _Station() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String region,  double lat,  double lon,  StationKind kind,  bool coordApprox,  String? iocCode,  String? iocSensor,  String? tideAsset,  String? river,  String? kttvKey,  bool tidal,  double? seaRefLat,  double? seaRefLon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Station() when $default != null:
return $default(_that.id,_that.name,_that.region,_that.lat,_that.lon,_that.kind,_that.coordApprox,_that.iocCode,_that.iocSensor,_that.tideAsset,_that.river,_that.kttvKey,_that.tidal,_that.seaRefLat,_that.seaRefLon);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String region,  double lat,  double lon,  StationKind kind,  bool coordApprox,  String? iocCode,  String? iocSensor,  String? tideAsset,  String? river,  String? kttvKey,  bool tidal,  double? seaRefLat,  double? seaRefLon)  $default,) {final _that = this;
switch (_that) {
case _Station():
return $default(_that.id,_that.name,_that.region,_that.lat,_that.lon,_that.kind,_that.coordApprox,_that.iocCode,_that.iocSensor,_that.tideAsset,_that.river,_that.kttvKey,_that.tidal,_that.seaRefLat,_that.seaRefLon);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String region,  double lat,  double lon,  StationKind kind,  bool coordApprox,  String? iocCode,  String? iocSensor,  String? tideAsset,  String? river,  String? kttvKey,  bool tidal,  double? seaRefLat,  double? seaRefLon)?  $default,) {final _that = this;
switch (_that) {
case _Station() when $default != null:
return $default(_that.id,_that.name,_that.region,_that.lat,_that.lon,_that.kind,_that.coordApprox,_that.iocCode,_that.iocSensor,_that.tideAsset,_that.river,_that.kttvKey,_that.tidal,_that.seaRefLat,_that.seaRefLon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Station implements Station {
  const _Station({required this.id, required this.name, required this.region, required this.lat, required this.lon, required this.kind, this.coordApprox = false, this.iocCode, this.iocSensor, this.tideAsset, this.river, this.kttvKey, this.tidal = false, this.seaRefLat, this.seaRefLon});
  factory _Station.fromJson(Map<String, dynamic> json) => _$StationFromJson(json);

@override final  String id;
@override final  String name;
@override final  String region;
@override final  double lat;
@override final  double lon;
@override final  StationKind kind;
@override@JsonKey() final  bool coordApprox;
@override final  String? iocCode;
@override final  String? iocSensor;
@override final  String? tideAsset;
/// River name for river stations ("Hồng").
@override final  String? river;
/// Station label as printed in the KTTV bulletin, spaces removed ("HàNội").
@override final  String? kttvKey;
/// Water oscillates with the sea tide here (bulletin says "dao động theo triều").
@override@JsonKey() final  bool tidal;
/// Sea point whose tide drives this river reach (Open-Meteo Marine).
@override final  double? seaRefLat;
@override final  double? seaRefLon;

/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StationCopyWith<_Station> get copyWith => __$StationCopyWithImpl<_Station>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Station&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.region, region) || other.region == region)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lon, lon) || other.lon == lon)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.coordApprox, coordApprox) || other.coordApprox == coordApprox)&&(identical(other.iocCode, iocCode) || other.iocCode == iocCode)&&(identical(other.iocSensor, iocSensor) || other.iocSensor == iocSensor)&&(identical(other.tideAsset, tideAsset) || other.tideAsset == tideAsset)&&(identical(other.river, river) || other.river == river)&&(identical(other.kttvKey, kttvKey) || other.kttvKey == kttvKey)&&(identical(other.tidal, tidal) || other.tidal == tidal)&&(identical(other.seaRefLat, seaRefLat) || other.seaRefLat == seaRefLat)&&(identical(other.seaRefLon, seaRefLon) || other.seaRefLon == seaRefLon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,region,lat,lon,kind,coordApprox,iocCode,iocSensor,tideAsset,river,kttvKey,tidal,seaRefLat,seaRefLon);
}

@override
String toString() {
    return 'Station(id: $id, name: $name, region: $region, lat: $lat, lon: $lon, kind: $kind, coordApprox: $coordApprox, iocCode: $iocCode, iocSensor: $iocSensor, tideAsset: $tideAsset, river: $river, kttvKey: $kttvKey, tidal: $tidal, seaRefLat: $seaRefLat, seaRefLon: $seaRefLon)';
}


}

/// @nodoc
abstract mixin class _$StationCopyWith<$Res> implements $StationCopyWith<$Res> {
  factory _$StationCopyWith(_Station value, $Res Function(_Station) _then) = __$StationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String region, double lat, double lon, StationKind kind, bool coordApprox, String? iocCode, String? iocSensor, String? tideAsset, String? river, String? kttvKey, bool tidal, double? seaRefLat, double? seaRefLon
});




}
/// @nodoc
class __$StationCopyWithImpl<$Res>
    implements _$StationCopyWith<$Res> {
  __$StationCopyWithImpl(this._self, this._then);

  final _Station _self;
  final $Res Function(_Station) _then;

/// Create a copy of Station
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? region = null,Object? lat = null,Object? lon = null,Object? kind = null,Object? coordApprox = null,Object? iocCode = freezed,Object? iocSensor = freezed,Object? tideAsset = freezed,Object? river = freezed,Object? kttvKey = freezed,Object? tidal = null,Object? seaRefLat = freezed,Object? seaRefLon = freezed,}) {
  return _then(_Station(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as StationKind,coordApprox: null == coordApprox ? _self.coordApprox : coordApprox // ignore: cast_nullable_to_non_nullable
as bool,iocCode: freezed == iocCode ? _self.iocCode : iocCode // ignore: cast_nullable_to_non_nullable
as String?,iocSensor: freezed == iocSensor ? _self.iocSensor : iocSensor // ignore: cast_nullable_to_non_nullable
as String?,tideAsset: freezed == tideAsset ? _self.tideAsset : tideAsset // ignore: cast_nullable_to_non_nullable
as String?,river: freezed == river ? _self.river : river // ignore: cast_nullable_to_non_nullable
as String?,kttvKey: freezed == kttvKey ? _self.kttvKey : kttvKey // ignore: cast_nullable_to_non_nullable
as String?,tidal: null == tidal ? _self.tidal : tidal // ignore: cast_nullable_to_non_nullable
as bool,seaRefLat: freezed == seaRefLat ? _self.seaRefLat : seaRefLat // ignore: cast_nullable_to_non_nullable
as double?,seaRefLon: freezed == seaRefLon ? _self.seaRefLon : seaRefLon // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
