import 'package:flutter/material.dart';
import 'package:rivertide/core/calc/ponds/release_parse.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// One editable "species + kg" line of a release.
class FishRow {
  FishRow(String species, int? kg)
    : name = TextEditingController(text: species),
      kg = TextEditingController(text: kg?.toString() ?? '');

  final TextEditingController name;
  final TextEditingController kg;

  void dispose() {
    name.dispose();
    kg.dispose();
  }
}

/// Non-empty rows as release fish (kg null when blank or not a number).
List<ReleaseFish> fishOf(List<FishRow> rows) => [
  for (final r in rows)
    if (r.name.text.trim().isNotEmpty)
      (species: r.name.text.trim(), kg: int.tryParse(r.kg.text.trim())),
];

class ReleaseFishEditor extends StatelessWidget {
  const ReleaseFishEditor({required this.rows, required this.onChanged, super.key});

  final List<FishRow> rows;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.sm,
      children: [
        Text(l10n.release_fish, style: context.text.label),
        for (final (i, r) in rows.indexed)
          Row(
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: r.name,
                  maxLength: 30,
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(labelText: l10n.release_fishName, counterText: ''),
                ),
              ),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: r.kg,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(labelText: l10n.release_fishKg, counterText: ''),
                ),
              ),
              IconButton(
                tooltip: l10n.journal_removePhoto,
                onPressed: () {
                  rows.removeAt(i).dispose();
                  onChanged();
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              rows.add(FishRow('', null));
              onChanged();
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.release_addFish),
          ),
        ),
      ],
    );
  }
}
