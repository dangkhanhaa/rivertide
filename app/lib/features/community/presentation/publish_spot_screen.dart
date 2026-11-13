import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/image/photo_clean.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/community/application/community_providers.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';
import 'package:rivertide/features/community/presentation/spot_form_parts.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Quick picks for what bites at a spot.
const List<String> _species = [
  'Cá chép', 'Cá rô phi', 'Cá trắm', 'Cá lóc', 'Cá mè', 'Cá trê', //
  'Cá rô đồng', 'Cá chẽm', 'Cá đối', 'Cá lăng', 'Cá bống', 'Tôm',
];

const int _maxPhotos = 3;

/// "Ghim điểm câu công khai" at a map point, or edit one's own spot ([editing]).
class PublishSpotScreen extends ConsumerStatefulWidget {
  const PublishSpotScreen({
    required this.lat,
    required this.lon,
    this.suggestedName,
    this.editing,
    super.key,
  });

  /// Opens the form on [spot] (P2-25).
  PublishSpotScreen.edit(PublicSpot spot, {super.key})
    : lat = spot.lat,
      lon = spot.lon,
      suggestedName = null,
      editing = spot;

  final double lat;
  final double lon;

  /// Prefilled from a searched place name.
  final String? suggestedName;
  final PublicSpot? editing;

  @override
  ConsumerState<PublishSpotScreen> createState() => _PublishSpotScreenState();
}

class _PublishSpotScreenState extends ConsumerState<PublishSpotScreen> {
  late final PublicSpot? _edit = widget.editing;
  late final _title = TextEditingController(text: _edit?.title ?? widget.suggestedName);
  late final _note = TextEditingController(text: _edit?.note);
  late final Set<String> _picked = {...?_edit?.species.split(',').map((s) => s.trim())}..remove('');
  late final List<SpotPhoto> _photos = [
    if (_edit case final e?)
      for (final (i, p) in e.photoPaths.indexed)
        if (i < e.photoUrls.length) StoredPhoto(p, e.photoUrls[i]),
  ];

  /// Editing an already public spot needs no second agreement.
  late bool _agreed = _edit != null;
  bool _sending = false;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 2000);
      if (file == null) return;
      final cleaned = cleanCatchPhoto(await file.readAsBytes());
      setState(() => _photos.add(NewPhoto(cleaned)));
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_photoError)));
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_photoError)));
    }
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final title = _title.text.trim();
    if (title.length < 2) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_needName)));
      return;
    }
    setState(() => _sending = true);
    final spot = NewSpot(
      title: title,
      note: _note.text.trim(),
      species: _picked.join(', '),
      lat: widget.lat,
      lon: widget.lon,
    );
    final added = [
      for (final p in _photos)
        if (p is NewPhoto) p.bytes,
    ];
    try {
      if (_edit case final e?) {
        final keep = [
          for (final p in _photos)
            if (p is StoredPhoto) p.path,
        ];
        await updateSpot(ref, e, spot, keep, added);
      } else {
        await publishSpot(ref, spot, added);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(_edit == null ? l10n.spot_published : l10n.spot_editSaved)),
      );
      nav.pop(true);
    } on AppException catch (e) {
      final text = e is RateLimitedException ? l10n.spot_tooMany : l10n.spot_error;
      messenger.showSnackBar(SnackBar(content: Text(text)));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final coords = '${widget.lat.toStringAsFixed(5)}, ${widget.lon.toStringAsFixed(5)}';
    final editing = _edit != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? l10n.spot_editTitle : l10n.spot_publishTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.spot_location(coords), style: context.text.body),
          if (adminLine(ref, widget.lat, widget.lon) case final a?)
            Text(a, style: context.text.caption),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _title,
            maxLength: 80,
            decoration: InputDecoration(labelText: l10n.spot_name, hintText: l10n.spot_nameHint),
          ),
          Text(l10n.spot_species, style: context.text.label),
          const SizedBox(height: AppSpacing.xs),
          _SpeciesChips(
            picked: _picked,
            onToggle: (s, {required on}) => setState(() {
              on ? _picked.add(s) : _picked.remove(s);
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _note,
            maxLength: 500,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.spot_note, hintText: l10n.spot_noteHint),
          ),
          Text(l10n.spot_photos, style: context.text.label),
          const SizedBox(height: AppSpacing.xs),
          SpotPhotoStrip(
            photos: _photos,
            onAdd: _photos.length < _maxPhotos ? () => unawaited(_addPhoto()) : null,
            onRemove: (i) => setState(() => _photos.removeAt(i)),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!editing) ...[
            SpotPublicNotice(agreed: _agreed, onChanged: (v) => setState(() => _agreed = v)),
            const SizedBox(height: AppSpacing.md),
          ],
          FilledButton.icon(
            onPressed: _agreed && !_sending ? () => unawaited(_submit()) : null,
            icon: _sending
                ? const SizedBox.square(
                    dimension: AppIconSize.sm,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(editing ? Icons.check_rounded : Icons.push_pin_rounded),
            label: Text(editing ? l10n.spot_save : l10n.spot_publish),
          ),
        ],
      ),
    );
  }
}

/// Common species plus any the spot already lists (kept when editing).
class _SpeciesChips extends StatelessWidget {
  const _SpeciesChips({required this.picked, required this.onToggle});

  final Set<String> picked;
  final void Function(String species, {required bool on}) onToggle;

  @override
  Widget build(BuildContext context) {
    final all = [..._species, ...picked.where((p) => !_species.contains(p))];
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final s in all)
          FilterChip(
            label: Text(s),
            selected: picked.contains(s),
            onSelected: (on) => onToggle(s, on: on),
          ),
      ],
    );
  }
}
