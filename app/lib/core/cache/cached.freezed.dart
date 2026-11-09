// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cached.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Cached<T> {

 T get data; DateTime get fetchedAtUtc;/// Past TTL or served from cache after a network error.
 bool get isStale;
/// Create a copy of Cached
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CachedCopyWith<T, Cached<T>> get copyWith => _$CachedCopyWithImpl<T, Cached<T>>(this as Cached<T>, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Cached<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cached<T>&&const DeepCollectionEquality().equals(other.data, _this.data)&&(identical(other.fetchedAtUtc, _this.fetchedAtUtc) || other.fetchedAtUtc == _this.fetchedAtUtc)&&(identical(other.isStale, _this.isStale) || other.isStale == _this.isStale));
}


@override
int get hashCode {
  final _this = this as Cached<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.data),_this.fetchedAtUtc,_this.isStale);
}

@override
String toString() {
  final _this = this as Cached<T>;
  return 'Cached<$T>(data: ${_this.data}, fetchedAtUtc: ${_this.fetchedAtUtc}, isStale: ${_this.isStale})';
}


}

/// @nodoc
abstract mixin class $CachedCopyWith<T,$Res>  {
  factory $CachedCopyWith(Cached<T> value, $Res Function(Cached<T>) _then) = _$CachedCopyWithImpl;
@useResult
$Res call({
 T data, DateTime fetchedAtUtc, bool isStale
});




}
/// @nodoc
class _$CachedCopyWithImpl<T,$Res>
    implements $CachedCopyWith<T, $Res> {
  _$CachedCopyWithImpl(this._self, this._then);

  final Cached<T> _self;
  final $Res Function(Cached<T>) _then;

/// Create a copy of Cached
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? fetchedAtUtc = null,Object? isStale = null,}) {
  return _then(Cached(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,fetchedAtUtc: null == fetchedAtUtc ? _self.fetchedAtUtc : fetchedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,isStale: null == isStale ? _self.isStale : isStale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Cached].
extension CachedPatterns<T> on Cached<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cached<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cached() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cached<T> value)  $default,){
final _that = this;
switch (_that) {
case _Cached():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cached<T> value)?  $default,){
final _that = this;
switch (_that) {
case _Cached() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T data,  DateTime fetchedAtUtc,  bool isStale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cached() when $default != null:
return $default(_that.data,_that.fetchedAtUtc,_that.isStale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T data,  DateTime fetchedAtUtc,  bool isStale)  $default,) {final _that = this;
switch (_that) {
case _Cached():
return $default(_that.data,_that.fetchedAtUtc,_that.isStale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T data,  DateTime fetchedAtUtc,  bool isStale)?  $default,) {final _that = this;
switch (_that) {
case _Cached() when $default != null:
return $default(_that.data,_that.fetchedAtUtc,_that.isStale);case _:
  return null;

}
}

}

/// @nodoc


class _Cached<T> implements Cached<T> {
  const _Cached({required this.data, required this.fetchedAtUtc, required this.isStale});
  

@override final  T data;
@override final  DateTime fetchedAtUtc;
/// Past TTL or served from cache after a network error.
@override final  bool isStale;

/// Create a copy of Cached
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CachedCopyWith<T, _Cached<T>> get copyWith => __$CachedCopyWithImpl<T, _Cached<T>>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cached<T>&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.fetchedAtUtc, fetchedAtUtc) || other.fetchedAtUtc == fetchedAtUtc)&&(identical(other.isStale, isStale) || other.isStale == isStale));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(data),fetchedAtUtc,isStale);
}

@override
String toString() {
    return 'Cached<$T>(data: $data, fetchedAtUtc: $fetchedAtUtc, isStale: $isStale)';
}


}

/// @nodoc
abstract mixin class _$CachedCopyWith<T,$Res> implements $CachedCopyWith<T, $Res> {
  factory _$CachedCopyWith(_Cached<T> value, $Res Function(_Cached<T>) _then) = __$CachedCopyWithImpl;
@override @useResult
$Res call({
 T data, DateTime fetchedAtUtc, bool isStale
});




}
/// @nodoc
class __$CachedCopyWithImpl<T,$Res>
    implements _$CachedCopyWith<T, $Res> {
  __$CachedCopyWithImpl(this._self, this._then);

  final _Cached<T> _self;
  final $Res Function(_Cached<T>) _then;

/// Create a copy of Cached
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? fetchedAtUtc = null,Object? isStale = null,}) {
  return _then(_Cached<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,fetchedAtUtc: null == fetchedAtUtc ? _self.fetchedAtUtc : fetchedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,isStale: null == isStale ? _self.isStale : isStale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
