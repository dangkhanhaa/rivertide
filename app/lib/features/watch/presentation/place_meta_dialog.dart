import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Limits keep the local database small and the list readable.
const int _maxLabel = 60;
const int _maxNote = 300;
const int _maxGroup = 40;

/// Name, note and group for one saved place.
Future<void> editPlaceMeta(
  BuildContext context,
  WidgetRef ref,
  SavedPlace fav,
  String stationName,
  List<String> existingGroups,
) async {
  final result = await showDialog<({String label, String note, String group})>(
    context: context,
    builder: (_) => _PlaceMetaDialog(fav: fav, stationName: stationName, groups: existingGroups),
  );
  if (result == null) return;
  await updateFavoriteMeta(
    ref,
    fav.stationId,
    label: result.label,
    note: result.note,
    group: result.group,
  );
}

class _PlaceMetaDialog extends StatefulWidget {
  const _PlaceMetaDialog({required this.fav, required this.stationName, required this.groups});

  final SavedPlace fav;
  final String stationName;
  final List<String> groups;

  @override
  State<_PlaceMetaDialog> createState() => _PlaceMetaDialogState();
}

class _PlaceMetaDialogState extends State<_PlaceMetaDialog> {
  late final _label = TextEditingController(text: widget.fav.label);
  late final _note = TextEditingController(text: widget.fav.note);
  late final _group = TextEditingController(text: widget.fav.group);

  @override
  void dispose() {
    _label.dispose();
    _note.dispose();
    _group.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.watch_editTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.md,
          children: [
            Text(widget.stationName, style: context.text.caption),
            TextField(
              controller: _label,
              maxLength: _maxLabel,
              decoration: InputDecoration(
                labelText: l10n.watch_label,
                hintText: l10n.watch_labelHint,
              ),
            ),
            TextField(
              controller: _note,
              maxLength: _maxNote,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.watch_note,
                hintText: l10n.watch_noteHint,
              ),
            ),
            TextField(
              controller: _group,
              maxLength: _maxGroup,
              decoration: InputDecoration(
                labelText: l10n.watch_group,
                hintText: l10n.watch_groupHint,
              ),
            ),
            if (widget.groups.isNotEmpty)
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final g in widget.groups)
                    ActionChip(label: Text(g), onPressed: () => setState(() => _group.text = g)),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.common_cancel)),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop((label: _label.text, note: _note.text, group: _group.text)),
          child: Text(l10n.common_save),
        ),
      ],
    );
  }
}
