import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Public photo bucket shared by community spots and ponds (0001 migration:
/// public read, anonymous upload only into `<uuid>/<name>.jpg`, ≤ 1 MB JPEG).
const String socialPhotoBucket = 'spot-photos';

String socialPhotoUrl(SupabaseClient db, String path) =>
    db.storage.from(socialPhotoBucket).getPublicUrl(path);

/// Uploads up to 3 cleaned JPEGs into a fresh random folder; returns their paths.
Future<List<String>> uploadSocialPhotos(SupabaseClient db, List<Uint8List> photos) async {
  if (photos.isEmpty) return const [];
  final folder = _uuidV4();
  final paths = <String>[];
  for (final (i, bytes) in photos.take(3).indexed) {
    final path = '$folder/p_$i.jpg';
    await db.storage
        .from(socialPhotoBucket)
        .uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
    paths.add(path);
  }
  return paths;
}

/// Random v4 UUID for a photo folder (the server checks the format).
String _uuidV4() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
      '${h.substring(16, 20)}-${h.substring(20)}';
}
