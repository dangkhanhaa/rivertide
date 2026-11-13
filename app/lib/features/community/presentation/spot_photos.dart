import 'package:flutter/material.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';

/// Swipeable photos with page dots.
class SpotPhotos extends StatefulWidget {
  const SpotPhotos({required this.urls, super.key});

  final List<String> urls;

  @override
  State<SpotPhotos> createState() => _SpotPhotosState();
}

class _SpotPhotosState extends State<SpotPhotos> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      spacing: AppSpacing.xs,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: PageView(
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                for (final u in widget.urls)
                  Image.network(
                    u,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: c.surfaceAlt,
                      child: Icon(Icons.broken_image_outlined, color: c.stale),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.urls.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSpacing.xs,
            children: [
              for (var i = 0; i < widget.urls.length; i++)
                Container(
                  width: AppSpacing.sm,
                  height: AppSpacing.sm,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page ? c.primary : c.stale.withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
