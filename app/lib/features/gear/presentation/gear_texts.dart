import 'package:flutter/widgets.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/features/gear/domain/gear_data.dart';

typedef KnotTexts = ({String name, String use, List<String> steps});

extension GearTexts on BuildContext {
  String tripName(TripKind k) => switch (k) {
    TripKind.common => l10n.gear_tabPack,
    TripKind.night => l10n.trip_night,
    TripKind.sea => l10n.trip_sea,
    TripKind.pond => l10n.trip_pond,
    TripKind.river => l10n.trip_river,
  };

  String gearName(GearItem g) => switch (g) {
    GearItem.rodReel => l10n.gear_rodReel,
    GearItem.spareLine => l10n.gear_spareLine,
    GearItem.hooksWeights => l10n.gear_hooksWeights,
    GearItem.baitChum => l10n.gear_baitChum,
    GearItem.netTowel => l10n.gear_netTowel,
    GearItem.waterFood => l10n.gear_waterFood,
    GearItem.sunHat => l10n.gear_sunHat,
    GearItem.raincoat => l10n.gear_raincoat,
    GearItem.phonePower => l10n.gear_phonePower,
    GearItem.trashBag => l10n.gear_trashBag,
    GearItem.headlamp => l10n.gear_headlamp,
    GearItem.glowSticks => l10n.gear_glowSticks,
    GearItem.mosquito => l10n.gear_mosquito,
    GearItem.jacket => l10n.gear_jacket,
    GearItem.nonSlipShoes => l10n.gear_nonSlipShoes,
    GearItem.lifeJacket => l10n.gear_lifeJacket,
    GearItem.tideCheck => l10n.gear_tideCheck,
    GearItem.leader => l10n.gear_leader,
    GearItem.pliers => l10n.gear_pliers,
    GearItem.pondCall => l10n.gear_pondCall,
    GearItem.chairUmbrella => l10n.gear_chairUmbrella,
    GearItem.keepNet => l10n.gear_keepNet,
    GearItem.boots => l10n.gear_boots,
    GearItem.rodRest => l10n.gear_rodRest,
  };

  /// Steps are one translated string, one step per line.
  KnotTexts knotTexts(Knot k) {
    final (name, use, steps) = switch (k) {
      Knot.improvedClinch => (
        l10n.knot_improvedClinch,
        l10n.knot_improvedClinch_use,
        l10n.knot_improvedClinch_steps,
      ),
      Knot.palomar => (l10n.knot_palomar, l10n.knot_palomar_use, l10n.knot_palomar_steps),
      Knot.uni => (l10n.knot_uni, l10n.knot_uni_use, l10n.knot_uni_steps),
      Knot.doubleUni => (l10n.knot_doubleUni, l10n.knot_doubleUni_use, l10n.knot_doubleUni_steps),
      Knot.perfectionLoop => (
        l10n.knot_perfectionLoop,
        l10n.knot_perfectionLoop_use,
        l10n.knot_perfectionLoop_steps,
      ),
      Knot.snell => (l10n.knot_snell, l10n.knot_snell_use, l10n.knot_snell_steps),
    };
    return (name: name, use: use, steps: steps.split('\n'));
  }
}
