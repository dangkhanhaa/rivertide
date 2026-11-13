import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivertide/core/calc/ponds/release_parse.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/image/photo_clean.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/community/community.dart';
import 'package:rivertide/features/ponds/application/ponds_providers.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Species offered as chips (display names from the release parser).
final List<String> _species = {for (final (_, n) in releaseSpecies) n}.toList();

/// Add a pond at a map point, or edit one ([editing]) (P2-28).
class PondFormScreen extends ConsumerStatefulWidget {
  const PondFormScreen({required this.lat, required this.lon, this.name, super.key})
    : editing = null;

  PondFormScreen.edit(Pond pond, {super.key})
    : lat = pond.lat,
      lon = pond.lon,
      name = pond.name,
      editing = pond;

  final double lat;
  final double lon;
  final String? name;
  final Pond? editing;

  @override
  ConsumerState<PondFormScreen> createState() => _PondFormScreenState();
}

class _PondFormScreenState extends ConsumerState<PondFormScreen> {
  late final Pond? _edit = widget.editing;
  late final _name = TextEditingController(text: widget.name);
  late final _address = TextEditingController(text: _edit?.address ?? '');
  late final _phone = TextEditingController(text: _edit?.phone);
  late final _price = TextEditingController(text: _edit?.price);
  late final _hours = TextEditingController(text: _edit?.hours);
  late final _note = TextEditingController(text: _edit?.note);
  late final Set<String> _picked = {...?_edit?.species};
  late final List<SpotPhoto> _photos = [
    if (_edit case final e?)
      for (final (i, p) in e.photoPaths.indexed)
        if (i < e.photoUrls.length) StoredPhoto(p, e.photoUrls[i]),
  ];
  bool _sending = false;

  @override
  void dispose() {
    for (final c in [_name, _address, _phone, _price, _hours, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 2000);
      if (file == null) return;
      final cleaned = cleanCatchPhoto(await file.readAsBytes());
      setState(() => _photos.add(NewPhoto(cleaned)));
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(l10n.spot_photoError)));
    }
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    if (_name.text.trim().length < 2) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pond_needName)));
      return;
    }
    final draft = PondDraft(
      name: _name.text.trim(),
      address: _address.text.trim(),
      lat: widget.lat,
      lon: widget.lon,
      phone: _phone.text.trim(),
      price: _price.text.trim(),
      hours: _hours.text.trim(),
      species: _picked.toList(),
      note: _note.text.trim(),
    );
    final added = [
      for (final p in _photos)
        if (p is NewPhoto) p.bytes,
    ];
    setState(() => _sending = true);
    try {
      if (_edit case final e?) {
        await updatePond(ref, e, draft, [
          for (final p in _photos)
            if (p is StoredPhoto) p.path,
        ], added);
      } else {
        await addPond(ref, draft, added);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(_edit == null ? l10n.pond_added : l10n.pond_saved)),
      );
      nav.pop(true);
    } on AppException catch (e) {
      final text = switch (e) {
        DuplicateException() => l10n.pond_duplicate,
        RateLimitedException() => l10n.pond_tooMany,
        _ => l10n.pond_error,
      };
      messenger.showSnackBar(SnackBar(content: Text(text)));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = _edit != null;
    if (_address.text.isEmpty && !editing) {
      if (adminLine(ref, widget.lat, widget.lon) case final a?) _address.text = a;
    }
    final coords = '${widget.lat.toStringAsFixed(5)}, ${widget.lon.toStringAsFixed(5)}';
    InputDecoration deco(String label, [String? hint]) =>
        InputDecoration(labelText: label, hintText: hint);
    return Scaffold(
      appBar: AppBar(title: Text(editing ? l10n.pond_editTitle : l10n.pond_addTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.pond_location(coords), style: context.text.body),
          Text(l10n.pond_locationHint, style: context.text.caption),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _name,
            maxLength: 100,
            decoration: deco(l10n.pond_name, l10n.pond_nameHint),
          ),
          TextField(controller: _address, maxLength: 200, decoration: deco(l10n.pond_address)),
          TextField(
            controller: _phone,
            maxLength: 30,
            keyboardType: TextInputType.phone,
            decoration: deco(l10n.pond_phone),
          ),
          TextField(
            controller: _price,
            maxLength: 120,
            decoration: deco(l10n.pond_price, l10n.pond_priceHint),
          ),
          TextField(
            controller: _hours,
            maxLength: 80,
            decoration: deco(l10n.pond_hours, l10n.pond_hoursHint),
          ),
          Text(l10n.pond_species, style: context.text.label),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final s in {..._species, ..._picked})
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
            maxLines: 4,
            minLines: 2,
            decoration: deco(l10n.pond_note),
          ),
          Text(l10n.spot_photos, style: context.text.label),
          const SizedBox(height: AppSpacing.xs),
          SpotPhotoStrip(
            photos: _photos,
            onAdd: _photos.length < 3 ? () => unawaited(_addPhoto()) : null,
            onRemove: (i) => setState(() => _photos.removeAt(i)),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _sending ? null : () => unawaited(_submit()),
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.pond_save),
          ),
        ],
      ),
    );
  }
}
