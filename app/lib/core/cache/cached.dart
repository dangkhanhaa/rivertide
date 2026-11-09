import 'package:freezed_annotation/freezed_annotation.dart';

part 'cached.freezed.dart';

/// Data plus freshness; every repository returns this (docs/rules/01 §4).
@freezed
abstract class Cached<T> with _$Cached<T> {
  const factory Cached({
    required T data,
    required DateTime fetchedAtUtc,

    /// Past TTL or served from cache after a network error.
    required bool isStale,
  }) = _Cached<T>;
}
