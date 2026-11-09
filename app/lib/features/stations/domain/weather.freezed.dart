// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeatherHour {

 DateTime get timeUtc; double? get temperatureC; double? get precipitationMm; double? get precipProbPct; int? get weatherCode; double? get cloudPct; double? get pressureHpa; double? get windKmh; double? get gustKmh; double? get windDirDeg; double? get capeJPerKg;
/// Create a copy of WeatherHour
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherHourCopyWith<WeatherHour> get copyWith => _$WeatherHourCopyWithImpl<WeatherHour>(this as WeatherHour, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WeatherHour;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherHour&&(identical(other.timeUtc, _this.timeUtc) || other.timeUtc == _this.timeUtc)&&(identical(other.temperatureC, _this.temperatureC) || other.temperatureC == _this.temperatureC)&&(identical(other.precipitationMm, _this.precipitationMm) || other.precipitationMm == _this.precipitationMm)&&(identical(other.precipProbPct, _this.precipProbPct) || other.precipProbPct == _this.precipProbPct)&&(identical(other.weatherCode, _this.weatherCode) || other.weatherCode == _this.weatherCode)&&(identical(other.cloudPct, _this.cloudPct) || other.cloudPct == _this.cloudPct)&&(identical(other.pressureHpa, _this.pressureHpa) || other.pressureHpa == _this.pressureHpa)&&(identical(other.windKmh, _this.windKmh) || other.windKmh == _this.windKmh)&&(identical(other.gustKmh, _this.gustKmh) || other.gustKmh == _this.gustKmh)&&(identical(other.windDirDeg, _this.windDirDeg) || other.windDirDeg == _this.windDirDeg)&&(identical(other.capeJPerKg, _this.capeJPerKg) || other.capeJPerKg == _this.capeJPerKg));
}


@override
int get hashCode {
  final _this = this as WeatherHour;
  return Object.hash(runtimeType,_this.timeUtc,_this.temperatureC,_this.precipitationMm,_this.precipProbPct,_this.weatherCode,_this.cloudPct,_this.pressureHpa,_this.windKmh,_this.gustKmh,_this.windDirDeg,_this.capeJPerKg);
}

@override
String toString() {
  final _this = this as WeatherHour;
  return 'WeatherHour(timeUtc: ${_this.timeUtc}, temperatureC: ${_this.temperatureC}, precipitationMm: ${_this.precipitationMm}, precipProbPct: ${_this.precipProbPct}, weatherCode: ${_this.weatherCode}, cloudPct: ${_this.cloudPct}, pressureHpa: ${_this.pressureHpa}, windKmh: ${_this.windKmh}, gustKmh: ${_this.gustKmh}, windDirDeg: ${_this.windDirDeg}, capeJPerKg: ${_this.capeJPerKg})';
}


}

/// @nodoc
abstract mixin class $WeatherHourCopyWith<$Res>  {
  factory $WeatherHourCopyWith(WeatherHour value, $Res Function(WeatherHour) _then) = _$WeatherHourCopyWithImpl;
@useResult
$Res call({
 DateTime timeUtc, double? temperatureC, double? precipitationMm, double? precipProbPct, int? weatherCode, double? cloudPct, double? pressureHpa, double? windKmh, double? gustKmh, double? windDirDeg, double? capeJPerKg
});




}
/// @nodoc
class _$WeatherHourCopyWithImpl<$Res>
    implements $WeatherHourCopyWith<$Res> {
  _$WeatherHourCopyWithImpl(this._self, this._then);

  final WeatherHour _self;
  final $Res Function(WeatherHour) _then;

/// Create a copy of WeatherHour
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timeUtc = null,Object? temperatureC = freezed,Object? precipitationMm = freezed,Object? precipProbPct = freezed,Object? weatherCode = freezed,Object? cloudPct = freezed,Object? pressureHpa = freezed,Object? windKmh = freezed,Object? gustKmh = freezed,Object? windDirDeg = freezed,Object? capeJPerKg = freezed,}) {
  return _then(WeatherHour(
timeUtc: null == timeUtc ? _self.timeUtc : timeUtc // ignore: cast_nullable_to_non_nullable
as DateTime,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,precipitationMm: freezed == precipitationMm ? _self.precipitationMm : precipitationMm // ignore: cast_nullable_to_non_nullable
as double?,precipProbPct: freezed == precipProbPct ? _self.precipProbPct : precipProbPct // ignore: cast_nullable_to_non_nullable
as double?,weatherCode: freezed == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int?,cloudPct: freezed == cloudPct ? _self.cloudPct : cloudPct // ignore: cast_nullable_to_non_nullable
as double?,pressureHpa: freezed == pressureHpa ? _self.pressureHpa : pressureHpa // ignore: cast_nullable_to_non_nullable
as double?,windKmh: freezed == windKmh ? _self.windKmh : windKmh // ignore: cast_nullable_to_non_nullable
as double?,gustKmh: freezed == gustKmh ? _self.gustKmh : gustKmh // ignore: cast_nullable_to_non_nullable
as double?,windDirDeg: freezed == windDirDeg ? _self.windDirDeg : windDirDeg // ignore: cast_nullable_to_non_nullable
as double?,capeJPerKg: freezed == capeJPerKg ? _self.capeJPerKg : capeJPerKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherHour].
extension WeatherHourPatterns on WeatherHour {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherHour value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherHour() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherHour value)  $default,){
final _that = this;
switch (_that) {
case _WeatherHour():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherHour value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherHour() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime timeUtc,  double? temperatureC,  double? precipitationMm,  double? precipProbPct,  int? weatherCode,  double? cloudPct,  double? pressureHpa,  double? windKmh,  double? gustKmh,  double? windDirDeg,  double? capeJPerKg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherHour() when $default != null:
return $default(_that.timeUtc,_that.temperatureC,_that.precipitationMm,_that.precipProbPct,_that.weatherCode,_that.cloudPct,_that.pressureHpa,_that.windKmh,_that.gustKmh,_that.windDirDeg,_that.capeJPerKg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime timeUtc,  double? temperatureC,  double? precipitationMm,  double? precipProbPct,  int? weatherCode,  double? cloudPct,  double? pressureHpa,  double? windKmh,  double? gustKmh,  double? windDirDeg,  double? capeJPerKg)  $default,) {final _that = this;
switch (_that) {
case _WeatherHour():
return $default(_that.timeUtc,_that.temperatureC,_that.precipitationMm,_that.precipProbPct,_that.weatherCode,_that.cloudPct,_that.pressureHpa,_that.windKmh,_that.gustKmh,_that.windDirDeg,_that.capeJPerKg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime timeUtc,  double? temperatureC,  double? precipitationMm,  double? precipProbPct,  int? weatherCode,  double? cloudPct,  double? pressureHpa,  double? windKmh,  double? gustKmh,  double? windDirDeg,  double? capeJPerKg)?  $default,) {final _that = this;
switch (_that) {
case _WeatherHour() when $default != null:
return $default(_that.timeUtc,_that.temperatureC,_that.precipitationMm,_that.precipProbPct,_that.weatherCode,_that.cloudPct,_that.pressureHpa,_that.windKmh,_that.gustKmh,_that.windDirDeg,_that.capeJPerKg);case _:
  return null;

}
}

}

/// @nodoc


class _WeatherHour implements WeatherHour {
  const _WeatherHour({required this.timeUtc, this.temperatureC, this.precipitationMm, this.precipProbPct, this.weatherCode, this.cloudPct, this.pressureHpa, this.windKmh, this.gustKmh, this.windDirDeg, this.capeJPerKg});
  

@override final  DateTime timeUtc;
@override final  double? temperatureC;
@override final  double? precipitationMm;
@override final  double? precipProbPct;
@override final  int? weatherCode;
@override final  double? cloudPct;
@override final  double? pressureHpa;
@override final  double? windKmh;
@override final  double? gustKmh;
@override final  double? windDirDeg;
@override final  double? capeJPerKg;

/// Create a copy of WeatherHour
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherHourCopyWith<_WeatherHour> get copyWith => __$WeatherHourCopyWithImpl<_WeatherHour>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherHour&&(identical(other.timeUtc, timeUtc) || other.timeUtc == timeUtc)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.precipitationMm, precipitationMm) || other.precipitationMm == precipitationMm)&&(identical(other.precipProbPct, precipProbPct) || other.precipProbPct == precipProbPct)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.cloudPct, cloudPct) || other.cloudPct == cloudPct)&&(identical(other.pressureHpa, pressureHpa) || other.pressureHpa == pressureHpa)&&(identical(other.windKmh, windKmh) || other.windKmh == windKmh)&&(identical(other.gustKmh, gustKmh) || other.gustKmh == gustKmh)&&(identical(other.windDirDeg, windDirDeg) || other.windDirDeg == windDirDeg)&&(identical(other.capeJPerKg, capeJPerKg) || other.capeJPerKg == capeJPerKg));
}


@override
int get hashCode {
    return Object.hash(runtimeType,timeUtc,temperatureC,precipitationMm,precipProbPct,weatherCode,cloudPct,pressureHpa,windKmh,gustKmh,windDirDeg,capeJPerKg);
}

@override
String toString() {
    return 'WeatherHour(timeUtc: $timeUtc, temperatureC: $temperatureC, precipitationMm: $precipitationMm, precipProbPct: $precipProbPct, weatherCode: $weatherCode, cloudPct: $cloudPct, pressureHpa: $pressureHpa, windKmh: $windKmh, gustKmh: $gustKmh, windDirDeg: $windDirDeg, capeJPerKg: $capeJPerKg)';
}


}

/// @nodoc
abstract mixin class _$WeatherHourCopyWith<$Res> implements $WeatherHourCopyWith<$Res> {
  factory _$WeatherHourCopyWith(_WeatherHour value, $Res Function(_WeatherHour) _then) = __$WeatherHourCopyWithImpl;
@override @useResult
$Res call({
 DateTime timeUtc, double? temperatureC, double? precipitationMm, double? precipProbPct, int? weatherCode, double? cloudPct, double? pressureHpa, double? windKmh, double? gustKmh, double? windDirDeg, double? capeJPerKg
});




}
/// @nodoc
class __$WeatherHourCopyWithImpl<$Res>
    implements _$WeatherHourCopyWith<$Res> {
  __$WeatherHourCopyWithImpl(this._self, this._then);

  final _WeatherHour _self;
  final $Res Function(_WeatherHour) _then;

/// Create a copy of WeatherHour
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timeUtc = null,Object? temperatureC = freezed,Object? precipitationMm = freezed,Object? precipProbPct = freezed,Object? weatherCode = freezed,Object? cloudPct = freezed,Object? pressureHpa = freezed,Object? windKmh = freezed,Object? gustKmh = freezed,Object? windDirDeg = freezed,Object? capeJPerKg = freezed,}) {
  return _then(_WeatherHour(
timeUtc: null == timeUtc ? _self.timeUtc : timeUtc // ignore: cast_nullable_to_non_nullable
as DateTime,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,precipitationMm: freezed == precipitationMm ? _self.precipitationMm : precipitationMm // ignore: cast_nullable_to_non_nullable
as double?,precipProbPct: freezed == precipProbPct ? _self.precipProbPct : precipProbPct // ignore: cast_nullable_to_non_nullable
as double?,weatherCode: freezed == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int?,cloudPct: freezed == cloudPct ? _self.cloudPct : cloudPct // ignore: cast_nullable_to_non_nullable
as double?,pressureHpa: freezed == pressureHpa ? _self.pressureHpa : pressureHpa // ignore: cast_nullable_to_non_nullable
as double?,windKmh: freezed == windKmh ? _self.windKmh : windKmh // ignore: cast_nullable_to_non_nullable
as double?,gustKmh: freezed == gustKmh ? _self.gustKmh : gustKmh // ignore: cast_nullable_to_non_nullable
as double?,windDirDeg: freezed == windDirDeg ? _self.windDirDeg : windDirDeg // ignore: cast_nullable_to_non_nullable
as double?,capeJPerKg: freezed == capeJPerKg ? _self.capeJPerKg : capeJPerKg // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
