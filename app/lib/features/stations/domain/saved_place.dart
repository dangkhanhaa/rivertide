/// A followed station or saved map point with the user's own name, note and group.
class SavedPlace {
  const SavedPlace({required this.stationId, this.label, this.note, this.group});

  final String stationId;
  final String? label;
  final String? note;
  final String? group;
}
