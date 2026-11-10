// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station_tide.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TideModelInfo {

 String get sourceName; TideConfidence get confidence; double? get rmseCm; double? get extremeTimeErrMin; double? get extremeHeightErrCm; String? get fitFrom; String? get fitTo;
/// Create a copy of TideModelInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TideModelInfoCopyWith<TideModelInfo> get copyWith => _$TideModelInfoCopyWithImpl<TideModelInfo>(this as TideModelInfo, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TideModelInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TideModelInfo&&(identical(other.sourceName, _this.sourceName) || other.sourceName == _this.sourceName)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.rmseCm, _this.rmseCm) || other.rmseCm == _this.rmseCm)&&(identical(other.extremeTimeErrMin, _this.extremeTimeErrMin) || other.extremeTimeErrMin == _this.extremeTimeErrMin)&&(identical(other.extremeHeightErrCm, _this.extremeHeightErrCm) || other.extremeHeightErrCm == _this.extremeHeightErrCm)&&(identical(other.fitFrom, _this.fitFrom) || other.fitFrom == _this.fitFrom)&&(identical(other.fitTo, _this.fitTo) || other.fitTo == _this.fitTo));
}


@override
int get hashCode {
  final _this = this as TideModelInfo;
  return Object.hash(runtimeType,_this.sourceName,_this.confidence,_this.rmseCm,_this.extremeTimeErrMin,_this.extremeHeightErrCm,_this.fitFrom,_this.fitTo);
}

@override
String toString() {
  final _this = this as TideModelInfo;
  return 'TideModelInfo(sourceName: ${_this.sourceName}, confidence: ${_this.confidence}, rmseCm: ${_this.rmseCm}, extremeTimeErrMin: ${_this.extremeTimeErrMin}, extremeHeightErrCm: ${_this.extremeHeightErrCm}, fitFrom: ${_this.fitFrom}, fitTo: ${_this.fitTo})';
}


}

/// @nodoc
abstract mixin class $TideModelInfoCopyWith<$Res>  {
  factory $TideModelInfoCopyWith(TideModelInfo value, $Res Function(TideModelInfo) _then) = _$TideModelInfoCopyWithImpl;
@useResult
$Res call({
 String sourceName, TideConfidence confidence, double? rmseCm, double? extremeTimeErrMin, double? extremeHeightErrCm, String? fitFrom, String? fitTo
});




}
/// @nodoc
class _$TideModelInfoCopyWithImpl<$Res>
    implements $TideModelInfoCopyWith<$Res> {
  _$TideModelInfoCopyWithImpl(this._self, this._then);

  final TideModelInfo _self;
  final $Res Function(TideModelInfo) _then;

/// Create a copy of TideModelInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceName = null,Object? confidence = null,Object? rmseCm = freezed,Object? extremeTimeErrMin = freezed,Object? extremeHeightErrCm = freezed,Object? fitFrom = freezed,Object? fitTo = freezed,}) {
  return _then(TideModelInfo(
sourceName: null == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as TideConfidence,rmseCm: freezed == rmseCm ? _self.rmseCm : rmseCm // ignore: cast_nullable_to_non_nullable
as double?,extremeTimeErrMin: freezed == extremeTimeErrMin ? _self.extremeTimeErrMin : extremeTimeErrMin // ignore: cast_nullable_to_non_nullable
as double?,extremeHeightErrCm: freezed == extremeHeightErrCm ? _self.extremeHeightErrCm : extremeHeightErrCm // ignore: cast_nullable_to_non_nullable
as double?,fitFrom: freezed == fitFrom ? _self.fitFrom : fitFrom // ignore: cast_nullable_to_non_nullable
as String?,fitTo: freezed == fitTo ? _self.fitTo : fitTo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TideModelInfo].
extension TideModelInfoPatterns on TideModelInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TideModelInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TideModelInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TideModelInfo value)  $default,){
final _that = this;
switch (_that) {
case _TideModelInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TideModelInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TideModelInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceName,  TideConfidence confidence,  double? rmseCm,  double? extremeTimeErrMin,  double? extremeHeightErrCm,  String? fitFrom,  String? fitTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TideModelInfo() when $default != null:
return $default(_that.sourceName,_that.confidence,_that.rmseCm,_that.extremeTimeErrMin,_that.extremeHeightErrCm,_that.fitFrom,_that.fitTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceName,  TideConfidence confidence,  double? rmseCm,  double? extremeTimeErrMin,  double? extremeHeightErrCm,  String? fitFrom,  String? fitTo)  $default,) {final _that = this;
switch (_that) {
case _TideModelInfo():
return $default(_that.sourceName,_that.confidence,_that.rmseCm,_that.extremeTimeErrMin,_that.extremeHeightErrCm,_that.fitFrom,_that.fitTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceName,  TideConfidence confidence,  double? rmseCm,  double? extremeTimeErrMin,  double? extremeHeightErrCm,  String? fitFrom,  String? fitTo)?  $default,) {final _that = this;
switch (_that) {
case _TideModelInfo() when $default != null:
return $default(_that.sourceName,_that.confidence,_that.rmseCm,_that.extremeTimeErrMin,_that.extremeHeightErrCm,_that.fitFrom,_that.fitTo);case _:
  return null;

}
}

}

/// @nodoc


class _TideModelInfo implements TideModelInfo {
  const _TideModelInfo({required this.sourceName, required this.confidence, this.rmseCm, this.extremeTimeErrMin, this.extremeHeightErrCm, this.fitFrom, this.fitTo});
  

@override final  String sourceName;
@override final  TideConfidence confidence;
@override final  double? rmseCm;
@override final  double? extremeTimeErrMin;
@override final  double? extremeHeightErrCm;
@override final  String? fitFrom;
@override final  String? fitTo;

/// Create a copy of TideModelInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TideModelInfoCopyWith<_TideModelInfo> get copyWith => __$TideModelInfoCopyWithImpl<_TideModelInfo>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TideModelInfo&&(identical(other.sourceName, sourceName) || other.sourceName == sourceName)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.rmseCm, rmseCm) || other.rmseCm == rmseCm)&&(identical(other.extremeTimeErrMin, extremeTimeErrMin) || other.extremeTimeErrMin == extremeTimeErrMin)&&(identical(other.extremeHeightErrCm, extremeHeightErrCm) || other.extremeHeightErrCm == extremeHeightErrCm)&&(identical(other.fitFrom, fitFrom) || other.fitFrom == fitFrom)&&(identical(other.fitTo, fitTo) || other.fitTo == fitTo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,sourceName,confidence,rmseCm,extremeTimeErrMin,extremeHeightErrCm,fitFrom,fitTo);
}

@override
String toString() {
    return 'TideModelInfo(sourceName: $sourceName, confidence: $confidence, rmseCm: $rmseCm, extremeTimeErrMin: $extremeTimeErrMin, extremeHeightErrCm: $extremeHeightErrCm, fitFrom: $fitFrom, fitTo: $fitTo)';
}


}

/// @nodoc
abstract mixin class _$TideModelInfoCopyWith<$Res> implements $TideModelInfoCopyWith<$Res> {
  factory _$TideModelInfoCopyWith(_TideModelInfo value, $Res Function(_TideModelInfo) _then) = __$TideModelInfoCopyWithImpl;
@override @useResult
$Res call({
 String sourceName, TideConfidence confidence, double? rmseCm, double? extremeTimeErrMin, double? extremeHeightErrCm, String? fitFrom, String? fitTo
});




}
/// @nodoc
class __$TideModelInfoCopyWithImpl<$Res>
    implements _$TideModelInfoCopyWith<$Res> {
  __$TideModelInfoCopyWithImpl(this._self, this._then);

  final _TideModelInfo _self;
  final $Res Function(_TideModelInfo) _then;

/// Create a copy of TideModelInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceName = null,Object? confidence = null,Object? rmseCm = freezed,Object? extremeTimeErrMin = freezed,Object? extremeHeightErrCm = freezed,Object? fitFrom = freezed,Object? fitTo = freezed,}) {
  return _then(_TideModelInfo(
sourceName: null == sourceName ? _self.sourceName : sourceName // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as TideConfidence,rmseCm: freezed == rmseCm ? _self.rmseCm : rmseCm // ignore: cast_nullable_to_non_nullable
as double?,extremeTimeErrMin: freezed == extremeTimeErrMin ? _self.extremeTimeErrMin : extremeTimeErrMin // ignore: cast_nullable_to_non_nullable
as double?,extremeHeightErrCm: freezed == extremeHeightErrCm ? _self.extremeHeightErrCm : extremeHeightErrCm // ignore: cast_nullable_to_non_nullable
as double?,fitFrom: freezed == fitFrom ? _self.fitFrom : fitFrom // ignore: cast_nullable_to_non_nullable
as String?,fitTo: freezed == fitTo ? _self.fitTo : fitTo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$DailyExtremes {

 int get windowHours; int get obsMaxCm; int get obsMinCm; int get fcMaxCm; int get fcMinCm; DateTime get issuedUtc;
/// Create a copy of DailyExtremes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyExtremesCopyWith<DailyExtremes> get copyWith => _$DailyExtremesCopyWithImpl<DailyExtremes>(this as DailyExtremes, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DailyExtremes;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyExtremes&&(identical(other.windowHours, _this.windowHours) || other.windowHours == _this.windowHours)&&(identical(other.obsMaxCm, _this.obsMaxCm) || other.obsMaxCm == _this.obsMaxCm)&&(identical(other.obsMinCm, _this.obsMinCm) || other.obsMinCm == _this.obsMinCm)&&(identical(other.fcMaxCm, _this.fcMaxCm) || other.fcMaxCm == _this.fcMaxCm)&&(identical(other.fcMinCm, _this.fcMinCm) || other.fcMinCm == _this.fcMinCm)&&(identical(other.issuedUtc, _this.issuedUtc) || other.issuedUtc == _this.issuedUtc));
}


@override
int get hashCode {
  final _this = this as DailyExtremes;
  return Object.hash(runtimeType,_this.windowHours,_this.obsMaxCm,_this.obsMinCm,_this.fcMaxCm,_this.fcMinCm,_this.issuedUtc);
}

@override
String toString() {
  final _this = this as DailyExtremes;
  return 'DailyExtremes(windowHours: ${_this.windowHours}, obsMaxCm: ${_this.obsMaxCm}, obsMinCm: ${_this.obsMinCm}, fcMaxCm: ${_this.fcMaxCm}, fcMinCm: ${_this.fcMinCm}, issuedUtc: ${_this.issuedUtc})';
}


}

/// @nodoc
abstract mixin class $DailyExtremesCopyWith<$Res>  {
  factory $DailyExtremesCopyWith(DailyExtremes value, $Res Function(DailyExtremes) _then) = _$DailyExtremesCopyWithImpl;
@useResult
$Res call({
 int windowHours, int obsMaxCm, int obsMinCm, int fcMaxCm, int fcMinCm, DateTime issuedUtc
});




}
/// @nodoc
class _$DailyExtremesCopyWithImpl<$Res>
    implements $DailyExtremesCopyWith<$Res> {
  _$DailyExtremesCopyWithImpl(this._self, this._then);

  final DailyExtremes _self;
  final $Res Function(DailyExtremes) _then;

/// Create a copy of DailyExtremes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? windowHours = null,Object? obsMaxCm = null,Object? obsMinCm = null,Object? fcMaxCm = null,Object? fcMinCm = null,Object? issuedUtc = null,}) {
  return _then(DailyExtremes(
windowHours: null == windowHours ? _self.windowHours : windowHours // ignore: cast_nullable_to_non_nullable
as int,obsMaxCm: null == obsMaxCm ? _self.obsMaxCm : obsMaxCm // ignore: cast_nullable_to_non_nullable
as int,obsMinCm: null == obsMinCm ? _self.obsMinCm : obsMinCm // ignore: cast_nullable_to_non_nullable
as int,fcMaxCm: null == fcMaxCm ? _self.fcMaxCm : fcMaxCm // ignore: cast_nullable_to_non_nullable
as int,fcMinCm: null == fcMinCm ? _self.fcMinCm : fcMinCm // ignore: cast_nullable_to_non_nullable
as int,issuedUtc: null == issuedUtc ? _self.issuedUtc : issuedUtc // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyExtremes].
extension DailyExtremesPatterns on DailyExtremes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyExtremes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyExtremes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyExtremes value)  $default,){
final _that = this;
switch (_that) {
case _DailyExtremes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyExtremes value)?  $default,){
final _that = this;
switch (_that) {
case _DailyExtremes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int windowHours,  int obsMaxCm,  int obsMinCm,  int fcMaxCm,  int fcMinCm,  DateTime issuedUtc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyExtremes() when $default != null:
return $default(_that.windowHours,_that.obsMaxCm,_that.obsMinCm,_that.fcMaxCm,_that.fcMinCm,_that.issuedUtc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int windowHours,  int obsMaxCm,  int obsMinCm,  int fcMaxCm,  int fcMinCm,  DateTime issuedUtc)  $default,) {final _that = this;
switch (_that) {
case _DailyExtremes():
return $default(_that.windowHours,_that.obsMaxCm,_that.obsMinCm,_that.fcMaxCm,_that.fcMinCm,_that.issuedUtc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int windowHours,  int obsMaxCm,  int obsMinCm,  int fcMaxCm,  int fcMinCm,  DateTime issuedUtc)?  $default,) {final _that = this;
switch (_that) {
case _DailyExtremes() when $default != null:
return $default(_that.windowHours,_that.obsMaxCm,_that.obsMinCm,_that.fcMaxCm,_that.fcMinCm,_that.issuedUtc);case _:
  return null;

}
}

}

/// @nodoc


class _DailyExtremes implements DailyExtremes {
  const _DailyExtremes({required this.windowHours, required this.obsMaxCm, required this.obsMinCm, required this.fcMaxCm, required this.fcMinCm, required this.issuedUtc});
  

@override final  int windowHours;
@override final  int obsMaxCm;
@override final  int obsMinCm;
@override final  int fcMaxCm;
@override final  int fcMinCm;
@override final  DateTime issuedUtc;

/// Create a copy of DailyExtremes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyExtremesCopyWith<_DailyExtremes> get copyWith => __$DailyExtremesCopyWithImpl<_DailyExtremes>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyExtremes&&(identical(other.windowHours, windowHours) || other.windowHours == windowHours)&&(identical(other.obsMaxCm, obsMaxCm) || other.obsMaxCm == obsMaxCm)&&(identical(other.obsMinCm, obsMinCm) || other.obsMinCm == obsMinCm)&&(identical(other.fcMaxCm, fcMaxCm) || other.fcMaxCm == fcMaxCm)&&(identical(other.fcMinCm, fcMinCm) || other.fcMinCm == fcMinCm)&&(identical(other.issuedUtc, issuedUtc) || other.issuedUtc == issuedUtc));
}


@override
int get hashCode {
    return Object.hash(runtimeType,windowHours,obsMaxCm,obsMinCm,fcMaxCm,fcMinCm,issuedUtc);
}

@override
String toString() {
    return 'DailyExtremes(windowHours: $windowHours, obsMaxCm: $obsMaxCm, obsMinCm: $obsMinCm, fcMaxCm: $fcMaxCm, fcMinCm: $fcMinCm, issuedUtc: $issuedUtc)';
}


}

/// @nodoc
abstract mixin class _$DailyExtremesCopyWith<$Res> implements $DailyExtremesCopyWith<$Res> {
  factory _$DailyExtremesCopyWith(_DailyExtremes value, $Res Function(_DailyExtremes) _then) = __$DailyExtremesCopyWithImpl;
@override @useResult
$Res call({
 int windowHours, int obsMaxCm, int obsMinCm, int fcMaxCm, int fcMinCm, DateTime issuedUtc
});




}
/// @nodoc
class __$DailyExtremesCopyWithImpl<$Res>
    implements _$DailyExtremesCopyWith<$Res> {
  __$DailyExtremesCopyWithImpl(this._self, this._then);

  final _DailyExtremes _self;
  final $Res Function(_DailyExtremes) _then;

/// Create a copy of DailyExtremes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? windowHours = null,Object? obsMaxCm = null,Object? obsMinCm = null,Object? fcMaxCm = null,Object? fcMinCm = null,Object? issuedUtc = null,}) {
  return _then(_DailyExtremes(
windowHours: null == windowHours ? _self.windowHours : windowHours // ignore: cast_nullable_to_non_nullable
as int,obsMaxCm: null == obsMaxCm ? _self.obsMaxCm : obsMaxCm // ignore: cast_nullable_to_non_nullable
as int,obsMinCm: null == obsMinCm ? _self.obsMinCm : obsMinCm // ignore: cast_nullable_to_non_nullable
as int,fcMaxCm: null == fcMaxCm ? _self.fcMaxCm : fcMaxCm // ignore: cast_nullable_to_non_nullable
as int,fcMinCm: null == fcMinCm ? _self.fcMinCm : fcMinCm // ignore: cast_nullable_to_non_nullable
as int,issuedUtc: null == issuedUtc ? _self.issuedUtc : issuedUtc // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$ReferenceStation {

 String get stationId; String get name; double get distanceKm; String? get river;/// Along-river position relative to the station (km, + upstream); null
/// when the point is not on the station's river line.
 double? get alongKm;/// Tide turns this many minutes later (+) / earlier (−) than at the station.
 double? get lagShiftMinutes;/// River mean level difference to the station now (cm).
 double? get meanShiftCm;/// Speed of the tide wave up this river (km/h).
 double? get celerityKmH;
/// Create a copy of ReferenceStation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReferenceStationCopyWith<ReferenceStation> get copyWith => _$ReferenceStationCopyWithImpl<ReferenceStation>(this as ReferenceStation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReferenceStation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReferenceStation&&(identical(other.stationId, _this.stationId) || other.stationId == _this.stationId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.distanceKm, _this.distanceKm) || other.distanceKm == _this.distanceKm)&&(identical(other.river, _this.river) || other.river == _this.river)&&(identical(other.alongKm, _this.alongKm) || other.alongKm == _this.alongKm)&&(identical(other.lagShiftMinutes, _this.lagShiftMinutes) || other.lagShiftMinutes == _this.lagShiftMinutes)&&(identical(other.meanShiftCm, _this.meanShiftCm) || other.meanShiftCm == _this.meanShiftCm)&&(identical(other.celerityKmH, _this.celerityKmH) || other.celerityKmH == _this.celerityKmH));
}


@override
int get hashCode {
  final _this = this as ReferenceStation;
  return Object.hash(runtimeType,_this.stationId,_this.name,_this.distanceKm,_this.river,_this.alongKm,_this.lagShiftMinutes,_this.meanShiftCm,_this.celerityKmH);
}

@override
String toString() {
  final _this = this as ReferenceStation;
  return 'ReferenceStation(stationId: ${_this.stationId}, name: ${_this.name}, distanceKm: ${_this.distanceKm}, river: ${_this.river}, alongKm: ${_this.alongKm}, lagShiftMinutes: ${_this.lagShiftMinutes}, meanShiftCm: ${_this.meanShiftCm}, celerityKmH: ${_this.celerityKmH})';
}


}

/// @nodoc
abstract mixin class $ReferenceStationCopyWith<$Res>  {
  factory $ReferenceStationCopyWith(ReferenceStation value, $Res Function(ReferenceStation) _then) = _$ReferenceStationCopyWithImpl;
@useResult
$Res call({
 String stationId, String name, double distanceKm, String? river, double? alongKm, double? lagShiftMinutes, double? meanShiftCm, double? celerityKmH
});




}
/// @nodoc
class _$ReferenceStationCopyWithImpl<$Res>
    implements $ReferenceStationCopyWith<$Res> {
  _$ReferenceStationCopyWithImpl(this._self, this._then);

  final ReferenceStation _self;
  final $Res Function(ReferenceStation) _then;

/// Create a copy of ReferenceStation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stationId = null,Object? name = null,Object? distanceKm = null,Object? river = freezed,Object? alongKm = freezed,Object? lagShiftMinutes = freezed,Object? meanShiftCm = freezed,Object? celerityKmH = freezed,}) {
  return _then(ReferenceStation(
stationId: null == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,river: freezed == river ? _self.river : river // ignore: cast_nullable_to_non_nullable
as String?,alongKm: freezed == alongKm ? _self.alongKm : alongKm // ignore: cast_nullable_to_non_nullable
as double?,lagShiftMinutes: freezed == lagShiftMinutes ? _self.lagShiftMinutes : lagShiftMinutes // ignore: cast_nullable_to_non_nullable
as double?,meanShiftCm: freezed == meanShiftCm ? _self.meanShiftCm : meanShiftCm // ignore: cast_nullable_to_non_nullable
as double?,celerityKmH: freezed == celerityKmH ? _self.celerityKmH : celerityKmH // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReferenceStation].
extension ReferenceStationPatterns on ReferenceStation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReferenceStation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReferenceStation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReferenceStation value)  $default,){
final _that = this;
switch (_that) {
case _ReferenceStation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReferenceStation value)?  $default,){
final _that = this;
switch (_that) {
case _ReferenceStation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stationId,  String name,  double distanceKm,  String? river,  double? alongKm,  double? lagShiftMinutes,  double? meanShiftCm,  double? celerityKmH)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReferenceStation() when $default != null:
return $default(_that.stationId,_that.name,_that.distanceKm,_that.river,_that.alongKm,_that.lagShiftMinutes,_that.meanShiftCm,_that.celerityKmH);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stationId,  String name,  double distanceKm,  String? river,  double? alongKm,  double? lagShiftMinutes,  double? meanShiftCm,  double? celerityKmH)  $default,) {final _that = this;
switch (_that) {
case _ReferenceStation():
return $default(_that.stationId,_that.name,_that.distanceKm,_that.river,_that.alongKm,_that.lagShiftMinutes,_that.meanShiftCm,_that.celerityKmH);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stationId,  String name,  double distanceKm,  String? river,  double? alongKm,  double? lagShiftMinutes,  double? meanShiftCm,  double? celerityKmH)?  $default,) {final _that = this;
switch (_that) {
case _ReferenceStation() when $default != null:
return $default(_that.stationId,_that.name,_that.distanceKm,_that.river,_that.alongKm,_that.lagShiftMinutes,_that.meanShiftCm,_that.celerityKmH);case _:
  return null;

}
}

}

/// @nodoc


class _ReferenceStation implements ReferenceStation {
  const _ReferenceStation({required this.stationId, required this.name, required this.distanceKm, this.river, this.alongKm, this.lagShiftMinutes, this.meanShiftCm, this.celerityKmH});
  

@override final  String stationId;
@override final  String name;
@override final  double distanceKm;
@override final  String? river;
/// Along-river position relative to the station (km, + upstream); null
/// when the point is not on the station's river line.
@override final  double? alongKm;
/// Tide turns this many minutes later (+) / earlier (−) than at the station.
@override final  double? lagShiftMinutes;
/// River mean level difference to the station now (cm).
@override final  double? meanShiftCm;
/// Speed of the tide wave up this river (km/h).
@override final  double? celerityKmH;

/// Create a copy of ReferenceStation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReferenceStationCopyWith<_ReferenceStation> get copyWith => __$ReferenceStationCopyWithImpl<_ReferenceStation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReferenceStation&&(identical(other.stationId, stationId) || other.stationId == stationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.river, river) || other.river == river)&&(identical(other.alongKm, alongKm) || other.alongKm == alongKm)&&(identical(other.lagShiftMinutes, lagShiftMinutes) || other.lagShiftMinutes == lagShiftMinutes)&&(identical(other.meanShiftCm, meanShiftCm) || other.meanShiftCm == meanShiftCm)&&(identical(other.celerityKmH, celerityKmH) || other.celerityKmH == celerityKmH));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stationId,name,distanceKm,river,alongKm,lagShiftMinutes,meanShiftCm,celerityKmH);
}

@override
String toString() {
    return 'ReferenceStation(stationId: $stationId, name: $name, distanceKm: $distanceKm, river: $river, alongKm: $alongKm, lagShiftMinutes: $lagShiftMinutes, meanShiftCm: $meanShiftCm, celerityKmH: $celerityKmH)';
}


}

/// @nodoc
abstract mixin class _$ReferenceStationCopyWith<$Res> implements $ReferenceStationCopyWith<$Res> {
  factory _$ReferenceStationCopyWith(_ReferenceStation value, $Res Function(_ReferenceStation) _then) = __$ReferenceStationCopyWithImpl;
@override @useResult
$Res call({
 String stationId, String name, double distanceKm, String? river, double? alongKm, double? lagShiftMinutes, double? meanShiftCm, double? celerityKmH
});




}
/// @nodoc
class __$ReferenceStationCopyWithImpl<$Res>
    implements _$ReferenceStationCopyWith<$Res> {
  __$ReferenceStationCopyWithImpl(this._self, this._then);

  final _ReferenceStation _self;
  final $Res Function(_ReferenceStation) _then;

/// Create a copy of ReferenceStation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stationId = null,Object? name = null,Object? distanceKm = null,Object? river = freezed,Object? alongKm = freezed,Object? lagShiftMinutes = freezed,Object? meanShiftCm = freezed,Object? celerityKmH = freezed,}) {
  return _then(_ReferenceStation(
stationId: null == stationId ? _self.stationId : stationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,river: freezed == river ? _self.river : river // ignore: cast_nullable_to_non_nullable
as String?,alongKm: freezed == alongKm ? _self.alongKm : alongKm // ignore: cast_nullable_to_non_nullable
as double?,lagShiftMinutes: freezed == lagShiftMinutes ? _self.lagShiftMinutes : lagShiftMinutes // ignore: cast_nullable_to_non_nullable
as double?,meanShiftCm: freezed == meanShiftCm ? _self.meanShiftCm : meanShiftCm // ignore: cast_nullable_to_non_nullable
as double?,celerityKmH: freezed == celerityKmH ? _self.celerityKmH : celerityKmH // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc
mixin _$StationTide {

 Station get station; List<WaterObservation> get observations; LevelDataKind get predictionKind; TideSeries? get prediction; TideModelInfo? get model;/// False when nudging the forecast toward the last observation makes it worse
/// (river backtest: 11,3 cm with vs 8,9 cm without).
 bool get correctWithObservations; DailyExtremes? get dailyExtremes;/// For a map point: the station whose data stands in for it.
 ReferenceStation? get reference;
/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StationTideCopyWith<StationTide> get copyWith => _$StationTideCopyWithImpl<StationTide>(this as StationTide, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StationTide;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StationTide&&(identical(other.station, _this.station) || other.station == _this.station)&&const DeepCollectionEquality().equals(other.observations, _this.observations)&&(identical(other.predictionKind, _this.predictionKind) || other.predictionKind == _this.predictionKind)&&(identical(other.prediction, _this.prediction) || other.prediction == _this.prediction)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.correctWithObservations, _this.correctWithObservations) || other.correctWithObservations == _this.correctWithObservations)&&(identical(other.dailyExtremes, _this.dailyExtremes) || other.dailyExtremes == _this.dailyExtremes)&&(identical(other.reference, _this.reference) || other.reference == _this.reference));
}


@override
int get hashCode {
  final _this = this as StationTide;
  return Object.hash(runtimeType,_this.station,const DeepCollectionEquality().hash(_this.observations),_this.predictionKind,_this.prediction,_this.model,_this.correctWithObservations,_this.dailyExtremes,_this.reference);
}

@override
String toString() {
  final _this = this as StationTide;
  return 'StationTide(station: ${_this.station}, observations: ${_this.observations}, predictionKind: ${_this.predictionKind}, prediction: ${_this.prediction}, model: ${_this.model}, correctWithObservations: ${_this.correctWithObservations}, dailyExtremes: ${_this.dailyExtremes}, reference: ${_this.reference})';
}


}

/// @nodoc
abstract mixin class $StationTideCopyWith<$Res>  {
  factory $StationTideCopyWith(StationTide value, $Res Function(StationTide) _then) = _$StationTideCopyWithImpl;
@useResult
$Res call({
 Station station, List<WaterObservation> observations, LevelDataKind predictionKind, TideSeries? prediction, TideModelInfo? model, bool correctWithObservations, DailyExtremes? dailyExtremes, ReferenceStation? reference
});


$StationCopyWith<$Res> get station;$TideModelInfoCopyWith<$Res>? get model;$DailyExtremesCopyWith<$Res>? get dailyExtremes;$ReferenceStationCopyWith<$Res>? get reference;

}
/// @nodoc
class _$StationTideCopyWithImpl<$Res>
    implements $StationTideCopyWith<$Res> {
  _$StationTideCopyWithImpl(this._self, this._then);

  final StationTide _self;
  final $Res Function(StationTide) _then;

/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? station = null,Object? observations = null,Object? predictionKind = null,Object? prediction = freezed,Object? model = freezed,Object? correctWithObservations = null,Object? dailyExtremes = freezed,Object? reference = freezed,}) {
  return _then(StationTide(
station: null == station ? _self.station : station // ignore: cast_nullable_to_non_nullable
as Station,observations: null == observations ? _self.observations : observations // ignore: cast_nullable_to_non_nullable
as List<WaterObservation>,predictionKind: null == predictionKind ? _self.predictionKind : predictionKind // ignore: cast_nullable_to_non_nullable
as LevelDataKind,prediction: freezed == prediction ? _self.prediction : prediction // ignore: cast_nullable_to_non_nullable
as TideSeries?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as TideModelInfo?,correctWithObservations: null == correctWithObservations ? _self.correctWithObservations : correctWithObservations // ignore: cast_nullable_to_non_nullable
as bool,dailyExtremes: freezed == dailyExtremes ? _self.dailyExtremes : dailyExtremes // ignore: cast_nullable_to_non_nullable
as DailyExtremes?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as ReferenceStation?,
  ));
}
/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StationCopyWith<$Res> get station {
  
  return $StationCopyWith<$Res>(_self.station, (value) {
    return _then(_self.copyWith(station: value));
  });
}/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TideModelInfoCopyWith<$Res>? get model {
    if (_self.model == null) {
    return null;
  }

  return $TideModelInfoCopyWith<$Res>(_self.model!, (value) {
    return _then(_self.copyWith(model: value));
  });
}/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyExtremesCopyWith<$Res>? get dailyExtremes {
    if (_self.dailyExtremes == null) {
    return null;
  }

  return $DailyExtremesCopyWith<$Res>(_self.dailyExtremes!, (value) {
    return _then(_self.copyWith(dailyExtremes: value));
  });
}/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReferenceStationCopyWith<$Res>? get reference {
    if (_self.reference == null) {
    return null;
  }

  return $ReferenceStationCopyWith<$Res>(_self.reference!, (value) {
    return _then(_self.copyWith(reference: value));
  });
}
}


/// Adds pattern-matching-related methods to [StationTide].
extension StationTidePatterns on StationTide {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StationTide value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StationTide() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StationTide value)  $default,){
final _that = this;
switch (_that) {
case _StationTide():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StationTide value)?  $default,){
final _that = this;
switch (_that) {
case _StationTide() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Station station,  List<WaterObservation> observations,  LevelDataKind predictionKind,  TideSeries? prediction,  TideModelInfo? model,  bool correctWithObservations,  DailyExtremes? dailyExtremes,  ReferenceStation? reference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StationTide() when $default != null:
return $default(_that.station,_that.observations,_that.predictionKind,_that.prediction,_that.model,_that.correctWithObservations,_that.dailyExtremes,_that.reference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Station station,  List<WaterObservation> observations,  LevelDataKind predictionKind,  TideSeries? prediction,  TideModelInfo? model,  bool correctWithObservations,  DailyExtremes? dailyExtremes,  ReferenceStation? reference)  $default,) {final _that = this;
switch (_that) {
case _StationTide():
return $default(_that.station,_that.observations,_that.predictionKind,_that.prediction,_that.model,_that.correctWithObservations,_that.dailyExtremes,_that.reference);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Station station,  List<WaterObservation> observations,  LevelDataKind predictionKind,  TideSeries? prediction,  TideModelInfo? model,  bool correctWithObservations,  DailyExtremes? dailyExtremes,  ReferenceStation? reference)?  $default,) {final _that = this;
switch (_that) {
case _StationTide() when $default != null:
return $default(_that.station,_that.observations,_that.predictionKind,_that.prediction,_that.model,_that.correctWithObservations,_that.dailyExtremes,_that.reference);case _:
  return null;

}
}

}

/// @nodoc


class _StationTide extends StationTide {
  const _StationTide({required this.station, required  List<WaterObservation> observations, required this.predictionKind, this.prediction, this.model, this.correctWithObservations = true, this.dailyExtremes, this.reference}): _observations = observations,super._();
  

@override final  Station station;
 final  List<WaterObservation> _observations;
@override List<WaterObservation> get observations {
  if (_observations is EqualUnmodifiableListView) return _observations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_observations);
}

@override final  LevelDataKind predictionKind;
@override final  TideSeries? prediction;
@override final  TideModelInfo? model;
/// False when nudging the forecast toward the last observation makes it worse
/// (river backtest: 11,3 cm with vs 8,9 cm without).
@override@JsonKey() final  bool correctWithObservations;
@override final  DailyExtremes? dailyExtremes;
/// For a map point: the station whose data stands in for it.
@override final  ReferenceStation? reference;

/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StationTideCopyWith<_StationTide> get copyWith => __$StationTideCopyWithImpl<_StationTide>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StationTide&&(identical(other.station, station) || other.station == station)&&const DeepCollectionEquality().equals(other.observations, _observations)&&(identical(other.predictionKind, predictionKind) || other.predictionKind == predictionKind)&&(identical(other.prediction, prediction) || other.prediction == prediction)&&(identical(other.model, model) || other.model == model)&&(identical(other.correctWithObservations, correctWithObservations) || other.correctWithObservations == correctWithObservations)&&(identical(other.dailyExtremes, dailyExtremes) || other.dailyExtremes == dailyExtremes)&&(identical(other.reference, reference) || other.reference == reference));
}


@override
int get hashCode {
    return Object.hash(runtimeType,station,const DeepCollectionEquality().hash(_observations),predictionKind,prediction,model,correctWithObservations,dailyExtremes,reference);
}

@override
String toString() {
    return 'StationTide(station: $station, observations: $observations, predictionKind: $predictionKind, prediction: $prediction, model: $model, correctWithObservations: $correctWithObservations, dailyExtremes: $dailyExtremes, reference: $reference)';
}


}

/// @nodoc
abstract mixin class _$StationTideCopyWith<$Res> implements $StationTideCopyWith<$Res> {
  factory _$StationTideCopyWith(_StationTide value, $Res Function(_StationTide) _then) = __$StationTideCopyWithImpl;
@override @useResult
$Res call({
 Station station, List<WaterObservation> observations, LevelDataKind predictionKind, TideSeries? prediction, TideModelInfo? model, bool correctWithObservations, DailyExtremes? dailyExtremes, ReferenceStation? reference
});


@override $StationCopyWith<$Res> get station;@override $TideModelInfoCopyWith<$Res>? get model;@override $DailyExtremesCopyWith<$Res>? get dailyExtremes;@override $ReferenceStationCopyWith<$Res>? get reference;

}
/// @nodoc
class __$StationTideCopyWithImpl<$Res>
    implements _$StationTideCopyWith<$Res> {
  __$StationTideCopyWithImpl(this._self, this._then);

  final _StationTide _self;
  final $Res Function(_StationTide) _then;

/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? station = null,Object? observations = null,Object? predictionKind = null,Object? prediction = freezed,Object? model = freezed,Object? correctWithObservations = null,Object? dailyExtremes = freezed,Object? reference = freezed,}) {
  return _then(_StationTide(
station: null == station ? _self.station : station // ignore: cast_nullable_to_non_nullable
as Station,observations: null == observations ? _self._observations : observations // ignore: cast_nullable_to_non_nullable
as List<WaterObservation>,predictionKind: null == predictionKind ? _self.predictionKind : predictionKind // ignore: cast_nullable_to_non_nullable
as LevelDataKind,prediction: freezed == prediction ? _self.prediction : prediction // ignore: cast_nullable_to_non_nullable
as TideSeries?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as TideModelInfo?,correctWithObservations: null == correctWithObservations ? _self.correctWithObservations : correctWithObservations // ignore: cast_nullable_to_non_nullable
as bool,dailyExtremes: freezed == dailyExtremes ? _self.dailyExtremes : dailyExtremes // ignore: cast_nullable_to_non_nullable
as DailyExtremes?,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as ReferenceStation?,
  ));
}

/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StationCopyWith<$Res> get station {
  
  return $StationCopyWith<$Res>(_self.station, (value) {
    return _then(_self.copyWith(station: value));
  });
}/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TideModelInfoCopyWith<$Res>? get model {
    if (_self.model == null) {
    return null;
  }

  return $TideModelInfoCopyWith<$Res>(_self.model!, (value) {
    return _then(_self.copyWith(model: value));
  });
}/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DailyExtremesCopyWith<$Res>? get dailyExtremes {
    if (_self.dailyExtremes == null) {
    return null;
  }

  return $DailyExtremesCopyWith<$Res>(_self.dailyExtremes!, (value) {
    return _then(_self.copyWith(dailyExtremes: value));
  });
}/// Create a copy of StationTide
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReferenceStationCopyWith<$Res>? get reference {
    if (_self.reference == null) {
    return null;
  }

  return $ReferenceStationCopyWith<$Res>(_self.reference!, (value) {
    return _then(_self.copyWith(reference: value));
  });
}
}

// dart format on
