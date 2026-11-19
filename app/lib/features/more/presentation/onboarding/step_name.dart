import 'package:flutter/material.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';
import 'package:rivertide/features/more/domain/display_name_rules.dart';
import 'package:rivertide/features/more/presentation/onboarding/onboarding_parts.dart';
import 'package:rivertide/l10n/gen/app_localizations.dart';

/// Step 3: optional public name, checked as it is typed (P2-53).
class NameStep extends StatelessWidget {
  const NameStep({
    required this.controller,
    required this.issue,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;

  /// Problem to show under the field (null = none / not yet).
  final NameIssue? issue;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OnbStep(
      title: l10n.onb_nameTitle,
      body: l10n.onb_nameBody,
      children: [
        TextField(
          controller: controller,
          maxLength: displayNameMaxChars,
          textCapitalization: TextCapitalization.words,
          autocorrect: false,
          autofillHints: const [AutofillHints.nickname],
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmitted(),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_rounded),
            hintText: l10n.name_hint,
            errorText: switch (issue) {
              final i? => nameIssueText(l10n, i),
              null => null,
            },
            errorMaxLines: 3,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => _ShownAs(name: normalizeDisplayName(controller.text)),
        ),
      ],
    );
  }
}

String nameIssueText(AppLocalizations l10n, NameIssue issue) => switch (issue) {
  NameIssue.tooShort => l10n.onb_nameErrShort,
  NameIssue.tooLong => l10n.onb_nameErrLong,
  NameIssue.badChars => l10n.onb_nameErrChars,
  NameIssue.link => l10n.onb_nameErrLink,
  NameIssue.phone => l10n.onb_nameErrPhone,
  NameIssue.reserved => l10n.onb_nameErrReserved,
};

/// How the name will look on a comment: avatar letter and the name, or the
/// anonymous label when empty.
class _ShownAs extends StatelessWidget {
  const _ShownAs({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final shown = name.isEmpty ? context.l10n.cmt_anon : name;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          spacing: AppSpacing.md,
          children: [
            CircleAvatar(
              radius: AppSpacing.lg + AppSpacing.xs,
              backgroundColor: c.primary.withValues(alpha: 0.14),
              child: Text(
                shown.characters.first.toUpperCase(),
                style: context.text.title.copyWith(color: c.primary),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.onb_nameShownAs, style: context.text.caption),
                  Text(
                    shown,
                    style: context.text.bodyStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
