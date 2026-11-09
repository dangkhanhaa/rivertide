import 'package:flutter/material.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/widgets/detail_host.dart';

/// Frame for station/point details on the map: close button + scrollable body.
/// Used inside the phone bottom sheet and as the right-hand panel on wide screens.
class MapDetailPanel extends StatelessWidget {
  const MapDetailPanel({
    required this.child,
    required this.onClose,
    this.scrollController,
    super.key,
  });

  final Widget child;
  final VoidCallback onClose;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => DetailHost(
    close: onClose,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: IconButton(
              tooltip: context.l10n.map_close,
              icon: const Icon(Icons.close_rounded),
              onPressed: onClose,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(controller: scrollController, child: child),
        ),
      ],
    ),
  );
}
