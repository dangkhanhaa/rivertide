import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/image/photo_clean.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/community/application/community_providers.dart';
import 'package:rivertide/features/community/domain/public_spot.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Quick picks for what bites at a spot.
const List<String> _species = [
  'Cá chép', 'Cá rô phi', 'Cá trắm', 'Cá lóc', 'Cá mè', 'Cá trê', //
  'Cá rô đồng', 'Cá chẽm', 'Cá đối', 'Cá lăng', 'Cá bống', 'Tôm',
];

const int _maxPhotos = 3;

/// "Ghim điểm câu công khai" at a map point.
class PublishSpotScreen extends ConsumerStatefulWidget {
  const PublishSpotScreen({required this.lat, required this.lon, this.suggestedName, super.key});

  final double lat;
  final double lon;

  /// Prefilled from a searched place name.
  final String? suggestedName;

  @override
  ConsumerState<PublishSpotScreen> createState() => _PublishSpotScreenState();
}

class _PublishSpotScreenState extends ConsumerState<PublishSpotScreen> {
  late final _title = TextEditingController(text: widget.suggestedName);
  final _note = TextEditingController();
  final Set<String> _picked = {};
  final List<Uint8List> _photos = [];
  bool _agreed = false;
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
      setState(() => _photos.add(cleaned));
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_photoError)));
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_photoError)));
    }
  }

  Future<void> _publish() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final title = _title.text.trim();
    if (title.length < 2) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_needName)));
      return;
    }
    setState(() => _sending = true);
    try {
      await publishSpot(
        ref,
        NewSpot(
          title: title,
          note: _note.text.trim(),
          species: _picked.join(', '),
          lat: widget.lat,
          lon: widget.lon,
        ),
        _photos,
      );
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_published)));
      nav.pop();
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_error)));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final coords = '${widget.lat.toStringAsFixed(5)}, ${widget.lon.toStringAsFixed(5)}';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.spot_publishTitle)),
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
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final s in _species)
                FilterChip(
                  label: Text(s),
                  selected: _picked.contains(s),
                  onSelected: (on) => setState(() => on ? _picked.add(s) : _picked.remove(s)),
                ),
            ],
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
          _PhotoStrip(
            photos: _photos,
            onAdd: _photos.length < _maxPhotos ? () => unawaited(_addPhoto()) : null,
            onRemove: (i) => setState(() => _photos.removeAt(i)),
          ),
          const SizedBox(height: AppSpacing.md),
          _Notice(agreed: _agreed, onChanged: (v) => setState(() => _agreed = v)),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: _agreed && !_sending ? () => unawaited(_publish()) : null,
            icon: _sending
                ? const SizedBox.square(
                    dimension: AppIconSize.sm,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.push_pin_rounded),
            label: Text(l10n.spot_publish),
          ),
        ],
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.photos, required this.onAdd, required this.onRemove});

  final List<Uint8List> photos;
  final VoidCallback? onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const size = AppSpacing.xxl * 3;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (i, p) in photos.indexed)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.memory(p, width: size, height: size, fit: BoxFit.cover),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton.filledTonal(
                  tooltip: context.l10n.journal_removePhoto,
                  onPressed: () => onRemove(i),
                  icon: const Icon(Icons.close_rounded, size: AppIconSize.sm),
                ),
              ),
            ],
          ),
        if (onAdd case final add?)
          InkWell(
            onTap: add,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.all(color: c.stale),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: c.primary),
                  Text(context.l10n.spot_addPhoto, style: context.text.caption),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.agreed, required this.onChanged});

  final bool agreed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.alarm1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.spot_publicNotice, style: context.text.body),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: agreed,
            onChanged: (v) => onChanged(v ?? false),
            title: Text(context.l10n.spot_agree, style: context.text.bodyStrong),
          ),
        ],
      ),
    );
  }
}
