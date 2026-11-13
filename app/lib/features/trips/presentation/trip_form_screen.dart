import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/logging/log.dart';
import 'package:rivertide/core/social/social_backend.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/stations/stations.dart';
import 'package:rivertide/features/trips/application/trips_providers.dart';
import 'package:rivertide/features/trips/domain/trip.dart';
import 'package:rivertide/features/trips/presentation/trip_time_picker.dart';

/// Create a trip at a place, or edit one's own ([editing]) (P2-26).
class TripFormScreen extends ConsumerStatefulWidget {
  const TripFormScreen({required this.lat, required this.lon, this.placeName, super.key})
    : editing = null;

  TripFormScreen.edit(Trip trip, {super.key})
    : lat = trip.lat,
      lon = trip.lon,
      placeName = trip.placeName,
      editing = trip;

  final double lat;
  final double lon;
  final String? placeName;
  final Trip? editing;

  @override
  ConsumerState<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends ConsumerState<TripFormScreen> {
  late final Trip? _edit = widget.editing;
  late final _title = TextEditingController(text: _edit?.title);
  late final _place = TextEditingController(text: widget.placeName ?? '');
  late final _note = TextEditingController(text: _edit?.note);
  final _contact = TextEditingController();
  late TripTime _time = _edit == null
      ? TripTime.defaultFrom(ref.read(clockProvider)())
      : TripTime(startUtc: _edit.startsAt, hours: _edit.endsAt.difference(_edit.startsAt).inHours);
  late int _people = _edit?.maxPeople ?? 4;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // The contact is members-only: load it for the owner's edit form.
    if (_edit case final e?) {
      unawaited(
        ref.read(tripPrivateProvider(e.id).future).then(
          (p) {
            if (mounted && p != null) _contact.text = p.contact;
          },
          onError: (Object e) => log.info('trip contact not loaded', {'type': '${e.runtimeType}'}),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final c in [_title, _place, _note, _contact]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final now = ref.read(clockProvider)();
    final problem = _title.text.trim().length < 2
        ? l10n.trip_needName
        : (!_time.validAt(now)
              ? l10n.trip_badTime
              : (_people < (_edit?.memberCount ?? 0) ? l10n.trip_tooFew : null));
    if (problem != null) {
      messenger.showSnackBar(SnackBar(content: Text(problem)));
      return;
    }
    final draft = TripDraft(
      title: _title.text.trim(),
      note: _note.text.trim(),
      placeName: _place.text.trim(),
      lat: widget.lat,
      lon: widget.lon,
      startsAt: _time.startUtc,
      endsAt: _time.endUtc,
      maxPeople: _people,
      contact: _contact.text.trim(),
    );
    setState(() => _sending = true);
    try {
      if (_edit case final e?) {
        await updateTrip(ref, e.id, draft);
      } else {
        await createTrip(ref, draft);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(_edit == null ? l10n.trip_created : l10n.trip_saved)),
      );
      nav.pop(true);
    } on AppException catch (e) {
      final text = e is RateLimitedException ? l10n.trip_tooMany : l10n.trip_error;
      messenger.showSnackBar(SnackBar(content: Text(text)));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = _edit != null;
    // The ward/commune index loads in the background: fill the place once it is
    // there, unless the user already typed something.
    if (_place.text.isEmpty && !editing) {
      if (adminLine(ref, widget.lat, widget.lon) case final a?) _place.text = a;
    }
    return Scaffold(
      appBar: AppBar(title: Text(editing ? l10n.trip_editTitle : l10n.trip_formTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _title,
            maxLength: 80,
            decoration: InputDecoration(labelText: l10n.trip_name, hintText: l10n.trip_nameHint),
          ),
          TextField(
            controller: _place,
            maxLength: 80,
            enabled: !editing,
            decoration: InputDecoration(
              labelText: l10n.trip_place,
              hintText: l10n.trip_placeHint,
              helperText: editing ? null : l10n.trip_whereHint,
              helperMaxLines: 3,
            ),
          ),
          TripTimePicker(
            pointId: PointId.encode(widget.lat, widget.lon),
            value: _time,
            onChanged: (t) => setState(() => _time = t),
          ),
          const SizedBox(height: AppSpacing.md),
          _PeopleStepper(value: _people, onChanged: (v) => setState(() => _people = v)),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _contact,
            maxLength: 120,
            decoration: InputDecoration(
              labelText: l10n.trip_contact,
              hintText: l10n.trip_contactHint,
              helperText: l10n.trip_contactNote,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _note,
            maxLength: 500,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.trip_note, hintText: l10n.trip_noteHint),
          ),
          Text(l10n.trip_notice, style: context.text.caption),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: _sending ? null : () => unawaited(_submit()),
            icon: _sending
                ? const SizedBox.square(
                    dimension: AppIconSize.sm,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(editing ? Icons.check_rounded : Icons.group_add_rounded),
            label: Text(editing ? l10n.trip_save : l10n.trip_submit),
          ),
          const _NameHint(),
        ],
      ),
    );
  }
}

class _PeopleStepper extends StatelessWidget {
  const _PeopleStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(context.l10n.trip_people, style: context.text.label)),
      IconButton.outlined(
        onPressed: value > 2 ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove_rounded),
      ),
      SizedBox(
        width: AppSpacing.xxl,
        child: Text('$value', style: context.text.title, textAlign: TextAlign.center),
      ),
      IconButton.outlined(
        onPressed: value < 30 ? () => onChanged(value + 1) : null,
        icon: const Icon(Icons.add_rounded),
      ),
    ],
  );
}

/// Shows under which name the trip is posted.
class _NameHint extends ConsumerWidget {
  const _NameHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(displayNameProvider).value ?? '';
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        l10n.trip_owner(name.isEmpty ? l10n.cmt_anon : name),
        style: context.text.caption,
        textAlign: TextAlign.center,
      ),
    );
  }
}
