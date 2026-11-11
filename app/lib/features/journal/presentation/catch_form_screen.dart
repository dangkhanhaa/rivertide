import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/navigation/fishing_spot.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/journal/application/journal_providers.dart';
import 'package:rivertide/features/journal/data/catch_photo.dart';
import 'package:rivertide/features/stations/stations.dart';

/// Common Vietnamese freshwater/brackish catches, as quick picks.
const List<String> _commonSpecies = [
  'Cá chép', 'Cá rô phi', 'Cá trắm', 'Cá lóc', 'Cá mè', 'Cá trê', //
  'Cá rô đồng', 'Cá chẽm', 'Cá đối', 'Cá lăng', 'Cá basa', 'Cá bống',
];

const int _maxText = 200;

/// "Ghi mẻ cá" for the current fishing spot; conditions are added on save.
class CatchFormScreen extends ConsumerStatefulWidget {
  const CatchFormScreen({super.key});

  @override
  ConsumerState<CatchFormScreen> createState() => _CatchFormScreenState();
}

class _CatchFormScreenState extends ConsumerState<CatchFormScreen> {
  final _species = TextEditingController();
  final _weight = TextEditingController();
  final _length = TextEditingController();
  final _bait = TextEditingController();
  final _note = TextEditingController();
  late DateTime _whenUtc = ref.read(clockProvider)();
  Uint8List? _photo;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_species, _weight, _length, _bait, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  /// "1,5" or "1.5" → 1.5; empty, invalid or out of range → null.
  double? _num(TextEditingController c, double max) {
    final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
    return v == null || v <= 0 || v > max ? null : v;
  }

  String? _text(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await ImagePicker().pickImage(source: source, maxWidth: 2000, imageQuality: 90);
      if (file == null) return;
      final cleaned = cleanCatchPhoto(await file.readAsBytes());
      setState(() => _photo = cleaned);
    } on AppException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.journal_photoError)));
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(l10n.journal_photoError)));
    }
  }

  Future<void> _pickTime() async {
    final local = TimeFormat.toVn(_whenUtc);
    final now = TimeFormat.toVn(ref.read(clockProvider)());
    final date = await showDatePicker(
      context: context,
      initialDate: local,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: local.hour, minute: local.minute),
    );
    if (time == null) return;
    // Picked fields are Vietnam wall-clock time.
    final picked = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).subtract(vnOffset);
    setState(() => _whenUtc = picked);
  }

  Future<void> _save(Station place) async {
    final species = _text(_species);
    if (species == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.journal_needSpecies)));
      return;
    }
    setState(() => _saving = true);
    await saveCatch(
      ref,
      CatchInput(
        placeId: place.id,
        placeName: place.name,
        lat: place.lat,
        lon: place.lon,
        caughtAtUtc: _whenUtc,
        species: species,
        weightKg: _num(_weight, 500),
        lengthCm: _num(_length, 500),
        bait: _text(_bait),
        note: _text(_note),
        photo: _photo,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spot = ref.watch(fishingSpotProvider);
    final place = ref.watch(stationByIdProvider(spot.id)).value;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.journal_add)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.journal_place(place?.name ?? '…'), style: context.text.bodyStrong),
          Text(l10n.journal_placeHint, style: context.text.caption),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule_rounded),
            title: Text(
              '${TimeFormat.dayShort(_whenUtc)} ${TimeFormat.hm(_whenUtc)}',
              style: context.text.body,
            ),
            trailing: TextButton(onPressed: _pickTime, child: Text(l10n.journal_changeTime)),
          ),
          TextField(
            controller: _species,
            maxLength: _maxText,
            decoration: InputDecoration(labelText: l10n.journal_species),
          ),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final s in _commonSpecies)
                ActionChip(label: Text(s), onPressed: () => setState(() => _species.text = s)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            spacing: AppSpacing.md,
            children: [
              Expanded(child: _numberField(_weight, l10n.journal_weight)),
              Expanded(child: _numberField(_length, l10n.journal_length)),
            ],
          ),
          TextField(
            controller: _bait,
            maxLength: _maxText,
            decoration: InputDecoration(labelText: l10n.journal_bait),
          ),
          TextField(
            controller: _note,
            maxLength: _maxText,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(labelText: l10n.journal_note),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PhotoRow(
            photo: _photo,
            onPick: _pickPhoto,
            onClear: () => setState(() => _photo = null),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: place == null || _saving ? null : () => unawaited(_save(place)),
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.common_save),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.journal_privacy, style: context.text.caption),
        ],
      ),
    );
  }

  Widget _numberField(TextEditingController c, String label) => TextField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label),
  );
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({required this.photo, required this.onPick, required this.onClear});

  final Uint8List? photo;
  final Future<void> Function(ImageSource) onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = photo;
    if (p != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.memory(p, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            right: AppSpacing.xs,
            top: AppSpacing.xs,
            child: IconButton.filledTonal(
              tooltip: l10n.journal_removePhoto,
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      );
    }
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        OutlinedButton.icon(
          onPressed: () => unawaited(onPick(ImageSource.camera)),
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(l10n.journal_camera),
        ),
        OutlinedButton.icon(
          onPressed: () => unawaited(onPick(ImageSource.gallery)),
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(l10n.journal_gallery),
        ),
      ],
    );
  }
}
