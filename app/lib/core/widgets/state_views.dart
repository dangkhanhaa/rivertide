import 'package:flutter/material.dart';
import 'package:rivertide/core/errors/app_exception.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Semantics(
        label: context.l10n.common_loading,
        child: const CircularProgressIndicator(),
      ),
    ),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({required this.error, this.onRetry, super.key});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = switch (error) {
      NetworkException() => l10n.error_network,
      TimeoutAppException() => l10n.error_timeout,
      ServerException() || RateLimitedException() => l10n.error_server,
      ParseException() => l10n.error_parse,
      NotFoundException() => l10n.error_notFound,
      OfflineNoCacheException() => l10n.error_offlineNoCache,
      _ => l10n.error_unknown,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: AppIconSize.lg, color: context.colors.alarm2),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: context.text.body, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: onRetry, child: Text(l10n.common_retry)),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({required this.message, this.action, super.key});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water_drop_outlined, size: AppIconSize.lg, color: context.colors.stale),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: context.text.body, textAlign: TextAlign.center),
          if (action case final a?) ...[const SizedBox(height: AppSpacing.lg), a],
        ],
      ),
    ),
  );
}

/// "Ngoại tuyến · cập nhật lúc 14:05" shown above stale data.
class StaleBanner extends StatelessWidget {
  const StaleBanner({required this.updatedAtText, super.key});

  final String updatedAtText;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: context.colors.alarm1.withValues(alpha: 0.25),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
    child: Row(
      children: [
        const Icon(Icons.wifi_off_rounded, size: AppIconSize.sm),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(context.l10n.common_staleBanner(updatedAtText), style: context.text.label),
        ),
      ],
    ),
  );
}
