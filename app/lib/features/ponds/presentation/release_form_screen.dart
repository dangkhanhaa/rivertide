import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/calc/ponds/release_parse.dart';
import 'package:rivertide/core/clock/clock_provider.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/ponds/application/ponds_providers.dart';
import 'package:rivertide/features/ponds/domain/pond.dart';
import 'package:rivertide/features/ponds/presentation/pond_format.dart';
import 'package:rivertide/features/ponds/presentation/widgets/release_fish_editor.dart';

const Duration _vn = Duration(hours: 7);

/// "Báo lịch xả cá": paste the pond's post and the app fills day, time and
/// fish (core/calc/ponds/release_parse.dart); everything stays editable.
class ReleaseFormScreen extends ConsumerStatefulWidget {
  const ReleaseFormScreen({required this.pond, super.key});

  final Pond pond;

  @override
  ConsumerState<ReleaseFormScreen> createState() => _ReleaseFormScreenState();
}

class _ReleaseFormScreenState extends ConsumerState<ReleaseFormScreen> {
  final _post = TextEditingController();
  DateTime? _day;
  TimeOfDay _time = const TimeOfDay(hour: 6, minute: 0);
  List<FishRow> _fish = [];
  bool _parsed = false;
  bool _sending = false;

  @override
  void dispose() {
    _post.dispose();
    for (final f in _fish) {
      f.dispose();
    }
    super.dispose();
  }

  void _read(String text) {
    final d = parseRelease(text, ref.read(clockProvider)());
    setState(() {
      _parsed = text.trim().isNotEmpty;
      if (d.dayLocal case final day?) _day = day;
      if (d.hour case final h?) _time = TimeOfDay(hour: h, minute: d.minute);
      if (d.fish.isNotEmpty) {
        for (final f in _fish) {
          f.dispose();
        }
        _fish = [for (final f in d.fish) FishRow(f.species, f.kg)];
      }
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    _post.text = text;
    _read(text);
  }

  Future<void> _pickDay() async {
    final today = ref.read(clockProvider)().add(_vn);
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? DateTime(today.year, today.month, today.day),
      firstDate: DateTime(today.year, today.month, today.day - 1),
      lastDate: DateTime(today.year, today.month, today.day + 59),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final day = _day;
    if (day == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.release_needDay)));
      return;
    }
    final start = DateTime.utc(
      day.year,
      day.month,
      day.day,
      _time.hour,
      _time.minute,
    ).subtract(_vn);
    setState(() => _sending = true);
    try {
      await postRelease(ref, widget.pond.id, start, fishOf(_fish), _post.text.trim());
      messenger.showSnackBar(SnackBar(content: Text(l10n.release_posted)));
      nav.pop();
    } on AppException catch (e) {
      final text = e is RateLimitedException ? l10n.pond_tooMany : l10n.pond_error;
      messenger.showSnackBar(SnackBar(content: Text(text)));
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final day = _day;
    final total = fishOf(_fish).map((f) => f.kg).nonNulls.fold<int>(0, (a, b) => a + b);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.release_title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(widget.pond.name, style: context.text.title),
          const SizedBox(height: AppSpacing.md),
          _PasteBox(controller: _post, onChanged: _read, onPaste: () => unawaited(_paste())),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.release_read, style: context.text.label),
          if (_parsed && day == null) Text(l10n.release_notFound, style: context.text.caption),
          const SizedBox(height: AppSpacing.xs),
          Row(
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => unawaited(_pickDay()),
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(day == null ? l10n.release_day : TimeFormat.dayShort(_utcOf(day))),
                ),
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => unawaited(_pickTime()),
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text(_time.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ReleaseFishEditor(rows: _fish, onChanged: () => setState(() {})),
          if (total > 0)
            Text(l10n.release_total(pondAmount(context, total)), style: context.text.bodyStrong),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.pond.mineOwner ? l10n.release_asOwner : l10n.release_asUser,
            style: context.text.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: _sending ? null : () => unawaited(_submit()),
            icon: const Icon(Icons.campaign_rounded),
            label: Text(l10n.release_post),
          ),
        ],
      ),
    );
  }

  /// Noon UTC of a local day: TimeFormat shows it as that Vietnam day.
  static DateTime _utcOf(DateTime day) => DateTime.utc(day.year, day.month, day.day, 5);
}

class _PasteBox extends StatelessWidget {
  const _PasteBox({required this.controller, required this.onChanged, required this.onPaste});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.pond.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.release_paste, style: context.text.bodyStrong)),
              FilledButton.tonalIcon(
                onPressed: onPaste,
                icon: const Icon(Icons.content_paste_rounded),
                label: Text(l10n.release_pasteButton),
              ),
            ],
          ),
          Text(l10n.release_pasteHint, style: context.text.caption),
          TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: 3,
            maxLines: 8,
            maxLength: 1000,
          ),
        ],
      ),
    );
  }
}
