import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rivertide/core/l10n/l10n_ext.dart';
import 'package:rivertide/core/theme/app_colors.dart';
import 'package:rivertide/core/theme/app_spacing.dart';
import 'package:rivertide/core/theme/app_text.dart';

/// A photo in the spot form: one already on the server (editing) or new.
sealed class SpotPhoto {
  const SpotPhoto();
}

final class StoredPhoto extends SpotPhoto {
  const StoredPhoto(this.path, this.url);

  final String path;
  final String url;
}

final class NewPhoto extends SpotPhoto {
  const NewPhoto(this.bytes);

  final Uint8List bytes;
}

class SpotPhotoStrip extends StatelessWidget {
  const SpotPhotoStrip({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  final List<SpotPhoto> photos;
  final VoidCallback? onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const size = AppSpacing.xxl * 3;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (i, p) in photos.indexed)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: switch (p) {
                  StoredPhoto(:final url) => Image.network(
                    url,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => SizedBox.square(
                      dimension: size,
                      child: Icon(Icons.broken_image_outlined, color: c.stale),
                    ),
                  ),
                  NewPhoto(:final bytes) => Image.memory(
                    bytes,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  ),
                },
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton.filledTonal(
                  tooltip: context.l10n.journal_removePhoto,
                  onPressed: () => onRemove(i),
                  icon: const Icon(Icons.close_rounded, size: AppIconSize.sm),
                ),
              ),
            ],
          ),
        if (onAdd case final add?)
          InkWell(
            onTap: add,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.all(color: c.stale),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: c.primary),
                  Text(context.l10n.spot_addPhoto, style: context.text.caption),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// "Điểm này sẽ công khai…" + the required checkbox.
class SpotPublicNotice extends StatelessWidget {
  const SpotPublicNotice({required this.agreed, required this.onChanged, super.key});

  final bool agreed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.alarm1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.spot_publicNotice, style: context.text.body),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: agreed,
            onChanged: (v) => onChanged(v ?? false),
            title: Text(context.l10n.spot_agree, style: context.text.bodyStrong),
          ),
        ],
      ),
    );
  }
}
