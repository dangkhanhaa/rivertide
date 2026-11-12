/// Public surface of the map feature for other features (CLAUDE.md 3.2).
library;

export 'application/map_providers.dart'
    show lastPositionProvider, locationPromptStoreProvider, locationServiceProvider;
export 'domain/location_service.dart'
    show LocateResult, Located, LocationDenied, LocationFailed, LocationService, LocationServiceOff;
export 'presentation/locate_action.dart' show runLocateFlow;
