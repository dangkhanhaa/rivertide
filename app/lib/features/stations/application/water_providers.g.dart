// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Remembered water kind of a point id; the point's tide depends on it, so a
/// new hint recomputes the tide wherever the point is shown (P2-47).

@ProviderFor(waterHint)
final waterHintProvider = WaterHintFamily._();

/// Remembered water kind of a point id; the point's tide depends on it, so a
/// new hint recomputes the tide wherever the point is shown (P2-47).

final class WaterHintProvider
    extends $FunctionalProvider<AsyncValue<WaterHint?>, WaterHint?, FutureOr<WaterHint?>>
    with $FutureModifier<WaterHint?>, $FutureProvider<WaterHint?> {
  /// Remembered water kind of a point id; the point's tide depends on it, so a
  /// new hint recomputes the tide wherever the point is shown (P2-47).
  WaterHintProvider._({required WaterHintFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'waterHintProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$waterHintHash();

  @override
  String toString() {
    return r'waterHintProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WaterHint?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<WaterHint?> create(Ref ref) {
    final argument = this.argument as String;
    return waterHint(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WaterHintProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$waterHintHash() => r'46f1570fddc90248b993b96a627c8613619be63e';

/// Remembered water kind of a point id; the point's tide depends on it, so a
/// new hint recomputes the tide wherever the point is shown (P2-47).

final class WaterHintFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WaterHint?>, String> {
  WaterHintFamily._()
    : super(
        retry: null,
        name: r'waterHintProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Remembered water kind of a point id; the point's tide depends on it, so a
  /// new hint recomputes the tide wherever the point is shown (P2-47).

  WaterHintProvider call(String id) => WaterHintProvider._(argument: id, from: this);

  @override
  String toString() => r'waterHintProvider';
}

/// OpenStreetMap around a map point (P2-52). Asked only when a screen shows
/// the point (a user action), cached 30 days. A better water kind than the
/// remembered one is saved, which recomputes the point's tide.

@ProviderFor(pointSurroundings)
final pointSurroundingsProvider = PointSurroundingsFamily._();

/// OpenStreetMap around a map point (P2-52). Asked only when a screen shows
/// the point (a user action), cached 30 days. A better water kind than the
/// remembered one is saved, which recomputes the point's tide.

final class PointSurroundingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PointSurroundings?>,
          PointSurroundings?,
          FutureOr<PointSurroundings?>
        >
    with $FutureModifier<PointSurroundings?>, $FutureProvider<PointSurroundings?> {
  /// OpenStreetMap around a map point (P2-52). Asked only when a screen shows
  /// the point (a user action), cached 30 days. A better water kind than the
  /// remembered one is saved, which recomputes the point's tide.
  PointSurroundingsProvider._({
    required PointSurroundingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pointSurroundingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pointSurroundingsHash();

  @override
  String toString() {
    return r'pointSurroundingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PointSurroundings?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PointSurroundings?> create(Ref ref) {
    final argument = this.argument as String;
    return pointSurroundings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PointSurroundingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pointSurroundingsHash() => r'08c2b3b5c1c47b14a8a3141faf8b62e49a9fa81d';

/// OpenStreetMap around a map point (P2-52). Asked only when a screen shows
/// the point (a user action), cached 30 days. A better water kind than the
/// remembered one is saved, which recomputes the point's tide.

final class PointSurroundingsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PointSurroundings?>, String> {
  PointSurroundingsFamily._()
    : super(
        retry: null,
        name: r'pointSurroundingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// OpenStreetMap around a map point (P2-52). Asked only when a screen shows
  /// the point (a user action), cached 30 days. A better water kind than the
  /// remembered one is saved, which recomputes the point's tide.

  PointSurroundingsProvider call(String id) =>
      PointSurroundingsProvider._(argument: id, from: this);

  @override
  String toString() => r'pointSurroundingsProvider';
}
