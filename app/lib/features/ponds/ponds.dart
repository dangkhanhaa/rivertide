/// Public surface of the ponds feature ("hồ câu dịch vụ", P2-28, CLAUDE.md 3.2).
library;

export 'application/ponds_providers.dart'
    show followedReleasesProvider, nearbyPondsProvider, pondsAreaKey, pondsRadiusKm;
export 'domain/pond.dart' show Pond, PondRelease;
export 'presentation/pond_detail.dart' show PondDetail, PondPage;
export 'presentation/pond_form_screen.dart' show PondFormScreen;
export 'presentation/ponds_screen.dart' show PondsScreen;
