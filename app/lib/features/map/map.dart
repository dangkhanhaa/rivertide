/// Public surface of the map feature for other features (CLAUDE.md 3.2).
library;

export 'application/map_providers.dart'
    show lastPositionProvider, locationPromptStoreProvider, locationServiceProvider;
export 'application/overlay_visibility.dart' show hiddenOverlaysProvider;
export 'domain/location_service.dart'
    show LocateResult, Located, LocationDenied, LocationFailed, LocationService, LocationServiceOff;
export 'presentation/locate_action.dart' show runLocateFlow;
export 'presentation/widgets/overlay_layers.dart' show MapOverlayId;
