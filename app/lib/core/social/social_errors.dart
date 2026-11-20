import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/format/time_format.dart';
import 'package:rivertide/core/social/content_filter.dart';
import 'package:rivertide/l10n/gen/app_localizations.dart';

/// User-facing text for a failed community write (P2-54): spam limits,
/// refused content and posting bans get their own message; anything else
/// shows [fallback]. [limit] replaces the generic text for a feature's own
/// rule (e.g. "one pond report per 30 minutes").
String socialErrorText(
  AppLocalizations l10n,
  Object error, {
  required String fallback,
  String? limit,
}) => switch (error) {
  ContentBlockedException(:final reason) => contentIssueText(l10n, ContentIssue.fromServer(reason)),
  BannedException(:final until?) => l10n.social_bannedUntil(
    '${TimeFormat.hm(until)} ${TimeFormat.dm(until)}',
  ),
  BannedException() => l10n.social_banned,
  RateLimitedException(kind: RateLimitKind.burst) => l10n.social_tooFast,
  RateLimitedException(kind: RateLimitKind.daily) => l10n.social_daily,
  RateLimitedException(kind: RateLimitKind.newDevice) => l10n.social_newDevice,
  RateLimitedException() => limit ?? l10n.social_tooFast,
  _ => fallback,
};

String contentIssueText(AppLocalizations l10n, ContentIssue issue) => switch (issue) {
  ContentIssue.link => l10n.blocked_link,
  ContentIssue.phone => l10n.blocked_phone,
  ContentIssue.contactAd => l10n.blocked_contactAd,
  ContentIssue.spam => l10n.blocked_spam,
  ContentIssue.offensive => l10n.blocked_offensive,
  ContentIssue.chars => l10n.blocked_chars,
  ContentIssue.shouting => l10n.blocked_shouting,
  ContentIssue.impersonation => l10n.blocked_impersonation,
  ContentIssue.repeat => l10n.blocked_repeat,
  ContentIssue.other => l10n.blocked_other,
};

/// Client-side pre-check: the message to show, or null when all fields pass.
String? contentPrecheck(AppLocalizations l10n, List<(String, ContentKind)> fields) {
  final issue = firstContentIssue(fields);
  return issue == null ? null : contentIssueText(l10n, issue);
}
