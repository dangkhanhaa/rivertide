import 'dart:convert';

/// Who uses the app, picked on the welcome flow's "Bạn là ai?" step (P2-53).
/// Used only on the device to choose sensible defaults; never sent.
enum UserKind { weekend, pro, pond, pondOwner, boater, tideOnly }

/// Waters the user mostly fishes.
enum FishingWater { river, sea, lake }

/// The user's answers; stored as JSON in the local settings table.
class UserProfile {
  const UserProfile({this.kinds = const {}, this.waters = const {}});

  /// Unknown or broken values are dropped (stored data is not trusted).
  factory UserProfile.fromJson(String? raw) {
    if (raw == null || raw.length > 500) return const UserProfile();
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const UserProfile();
    }
    if (decoded is! Map<String, Object?>) return const UserProfile();
    Set<T> pick<T extends Enum>(List<T> values, Object? list) => list is List
        ? {
            for (final v in values)
              if (list.contains(v.name)) v,
          }
        : <T>{};
    return UserProfile(
      kinds: pick(UserKind.values, decoded['kinds']),
      waters: pick(FishingWater.values, decoded['waters']),
    );
  }

  final Set<UserKind> kinds;
  final Set<FishingWater> waters;

  bool get isEmpty => kinds.isEmpty && waters.isEmpty;

  String toJson() => jsonEncode({
    'kinds': [for (final k in kinds) k.name],
    'waters': [for (final w in waters) w.name],
  });

  UserProfile toggleKind(UserKind k) => UserProfile(kinds: _toggle(kinds, k), waters: waters);

  UserProfile toggleWater(FishingWater w) => UserProfile(kinds: kinds, waters: _toggle(waters, w));

  static Set<T> _toggle<T>(Set<T> set, T v) =>
      set.contains(v) ? ({...set}..remove(v)) : {...set, v};

  /// Fishes mostly at service ponds: only pond kinds were picked, or no kind
  /// and only lakes.
  bool get pondFocused {
    const pondKinds = {UserKind.pond, UserKind.pondOwner};
    if (kinds.isNotEmpty) return kinds.every(pondKinds.contains);
    return waters.length == 1 && waters.first == FishingWater.lake;
  }

  /// Only watches the water (tide only / boat), without fishing at all.
  bool get watchesOnly =>
      kinds.isNotEmpty && kinds.every((k) => k == UserKind.tideOnly || k == UserKind.boater);
}
