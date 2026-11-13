import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fishing_spot.g.dart';

/// Fishing tab route, shared so features need not import the router.
const String fishingRoute = '/fishing';

/// "Hôm nay đi đâu?" screen (P2-21), opened from the map and the fishing tab.
const String whereRoute = '/where';

/// Hồ câu tab (P2-28).
const String pondsRoute = '/ponds';

/// Where the user plans to fish: a station id or a map point id ("pt-…").
typedef FishingSpotChoice = ({String id, bool mine});

/// Lives in core so the map/station sheets can set it ("Câu cá tại đây")
/// without importing the fishing feature.
@Riverpod(keepAlive: true)
class FishingSpot extends _$FishingSpot {
  /// Until the user chooses or is located: the Vũng Tàu gauge (real data).
  static const String fallbackId = 'ioc-vung';

  /// True once the user picked a spot; automatic location must not override it.
  bool userChose = false;

  @override
  FishingSpotChoice build() => (id: fallbackId, mine: false);

  void choose(String id, {bool mine = false, bool byUser = true}) {
    if (byUser) userChose = true;
    state = (id: id, mine: mine);
  }
}
