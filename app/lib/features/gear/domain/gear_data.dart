// Packing lists and knots (P2-38). Texts live in app_vi.arb (`gear_*`,
// `knot_*`); this file only says which items belong to which trip.

enum TripKind { common, night, sea, pond, river }

enum GearItem {
  rodReel,
  spareLine,
  hooksWeights,
  baitChum,
  netTowel,
  waterFood,
  sunHat,
  raincoat,
  phonePower,
  trashBag,
  headlamp,
  glowSticks,
  mosquito,
  jacket,
  nonSlipShoes,
  lifeJacket,
  tideCheck,
  leader,
  pliers,
  pondCall,
  chairUmbrella,
  keepNet,
  boots,
  rodRest,
}

const Map<TripKind, List<GearItem>> gearLists = {
  TripKind.common: [
    GearItem.rodReel,
    GearItem.spareLine,
    GearItem.hooksWeights,
    GearItem.baitChum,
    GearItem.netTowel,
    GearItem.waterFood,
    GearItem.sunHat,
    GearItem.raincoat,
    GearItem.phonePower,
    GearItem.trashBag,
  ],
  TripKind.night: [GearItem.headlamp, GearItem.glowSticks, GearItem.mosquito, GearItem.jacket],
  TripKind.sea: [
    GearItem.nonSlipShoes,
    GearItem.lifeJacket,
    GearItem.tideCheck,
    GearItem.leader,
    GearItem.pliers,
  ],
  TripKind.pond: [GearItem.pondCall, GearItem.chairUmbrella, GearItem.keepNet],
  TripKind.river: [GearItem.boots, GearItem.rodRest, GearItem.chairUmbrella],
};

/// Shape of the knot drawing: what the line is tied to and how many wraps.
enum KnotTarget { hookEye, lineToLine, loop }

enum Knot {
  improvedClinch(KnotTarget.hookEye, turns: 6, strength: 85),
  palomar(KnotTarget.hookEye, turns: 1, doubled: true, strength: 95),
  uni(KnotTarget.hookEye, turns: 5, strength: 90),
  doubleUni(KnotTarget.lineToLine, turns: 4, strength: 85),
  perfectionLoop(KnotTarget.loop, turns: 1, strength: 85),
  snell(KnotTarget.hookEye, turns: 7, strength: 95);

  Knot(this.target, {required this.turns, required this.strength, this.doubled = false});

  final KnotTarget target;

  /// Wraps drawn (and told in the steps).
  final int turns;

  /// Approximate share of line strength kept, % (commonly quoted figures).
  final int strength;

  /// Tied with the line folded double (Palomar).
  final bool doubled;
}
