/// Public surface of the stations feature for other features (CLAUDE.md 3.2).
library;

export 'application/hour_extras_provider.dart' show StationFishing, stationFishingProvider;
export 'application/station_providers.dart'
    show favoriteIdsProvider, stationByIdProvider, stationListProvider, stationTideProvider;
export 'application/station_view_providers.dart' show StationView, stationViewProvider;
export 'domain/point_id.dart' show PointId;
export 'domain/station.dart' show Station, StationKind;
export 'presentation/station_detail_screen.dart' show StationDetailScreen;
export 'presentation/stations_screen.dart' show StationsScreen;
export 'presentation/widgets/moon_text.dart' show MoonText;
export 'presentation/widgets/point_sheet.dart' show PointSheet;
export 'presentation/widgets/station_card.dart' show StationCard;
export 'presentation/widgets/station_sheet.dart' show StationSheet;
export 'presentation/widgets/tide_text.dart' show TideText, stationKindIcon;
