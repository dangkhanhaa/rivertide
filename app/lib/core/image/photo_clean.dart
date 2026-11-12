import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:rivertide/core/errors/app_exception.dart';

/// Longest side kept for a catch photo; enough for a phone screen.
const int catchPhotoMaxSide = 1280;

/// Larger files are refused before decoding (a phone photo is ~2–8 MB).
const int catchPhotoMaxInputBytes = 20 * 1024 * 1024;

/// Re-encodes [bytes] as a resized JPEG. Re-encoding drops all EXIF data, so
/// the photo does not carry the GPS position of the user's fishing spot.
Uint8List cleanCatchPhoto(Uint8List bytes) {
  if (bytes.length > catchPhotoMaxInputBytes) {
    throw const ParseException('photo too large');
  }
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const ParseException('photo not decodable');
  final upright = img.bakeOrientation(decoded);
  final longest = upright.width > upright.height ? upright.width : upright.height;
  final resized = longest <= catchPhotoMaxSide
      ? upright
      : img.copyResize(
          upright,
          width: upright.width >= upright.height ? catchPhotoMaxSide : null,
          height: upright.height > upright.width ? catchPhotoMaxSide : null,
        );
  return img.encodeJpg(resized, quality: 80);
}
