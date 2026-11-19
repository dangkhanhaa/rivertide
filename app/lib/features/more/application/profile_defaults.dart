import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/theme/appearance.dart';
import 'package:rivertide/features/map/map.dart';
import 'package:rivertide/features/more/application/appearance_provider.dart';
import 'package:rivertide/features/more/domain/user_profile.dart';

/// Defaults implied by the welcome-flow answers (P2-53), kept modest:
///
/// | Answer | Start tab | Map layers |
/// |---|---|---|
/// | only "câu hồ dịch vụ" / "chủ hồ câu" (or only lakes) | Hồ câu | all on |
/// | only "chỉ xem con nước" (± "đi biển") | Bản đồ | ponds, spots, trips, people fishing off |
/// | only "đi biển, thuyền" | Bản đồ | ponds off |
/// | anything else | Bản đồ | all on |
///
/// Nothing changes when no answer was given (skipped): the app defaults stay.
StartTab startTabFor(UserProfile p) => p.pondFocused ? StartTab.ponds : StartTab.map;

Set<MapOverlayId> hiddenLayersFor(UserProfile p) {
  if (!p.watchesOnly) return const {};
  if (p.kinds.contains(UserKind.tideOnly)) return MapOverlayId.values.toSet();
  return const {MapOverlayId.ponds};
}

Future<void> applyProfileDefaults(WidgetRef ref, UserProfile p) async {
  if (p.isEmpty) return;
  await ref
      .read(appearanceSettingsProvider.notifier)
      .change((l) => l.copyWith(startTab: startTabFor(p)));
  if (p.kinds.isEmpty) return;
  final hidden = hiddenLayersFor(p);
  final layers = ref.read(hiddenOverlaysProvider.notifier);
  for (final id in MapOverlayId.values) {
    await layers.setVisible(id.name, visible: !hidden.contains(id));
  }
}
