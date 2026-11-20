/// Coarse tidal regions of Vietnam (P2-48). Hand-drawn, approximate to a few
/// km: they only decide which rule set applies, the fine work is done by the
/// water kind, the distance to the sea and the ground height.
enum TideZone {
  /// Mekong delta and the Đồng Nai – Sài Gòn – Vàm Cỏ lowlands: an open
  /// network of rivers, canals and creeks where the sea tide reaches almost
  /// everywhere (up to Tân Châu/Châu Đốc in the dry season).
  south,

  /// Red River – Thái Bình delta: main rivers are tidal (weaker inland);
  /// irrigation canals and ditches are mostly behind sluice gates.
  north,

  /// Central coast and the rest: tide only near the river mouths.
  other,
}

/// (lat, lon) vertices. Seaward edges lie offshore on purpose (sea points are
/// decided by their kind, not the zone). Upland islands inside (Bảy Núi, the
/// Bình Dương – Đồng Nai hills, Chí Linh) are left to the height guard.
const List<(double, double)> _south = [
  (8.40, 104.60),
  (10.40, 104.40),
  (10.45, 104.55),
  (10.95, 105.05),
  (11.00, 105.60),
  (11.15, 106.10),
  (11.35, 106.35),
  (11.20, 106.75),
  (11.10, 107.05),
  (10.75, 107.20),
  (10.30, 107.30),
  (9.20, 106.80),
  (8.40, 105.20),
];

/// West edge just west of Hà Nội (tidal at Long Biên in the dry season),
/// north edge past Phủ Lạng Thương / Lục Nam (tidal KTTV stations), south to
/// Kim Sơn; Thanh Hóa's Mã River is handled by the "other" rules.
const List<(double, double)> _north = [
  (21.40, 105.70),
  (21.40, 106.55),
  (21.15, 106.80),
  (21.05, 107.05),
  (20.55, 107.05),
  (19.90, 106.20),
  (19.95, 105.90),
  (20.30, 105.80),
  (20.70, 105.65),
  (21.00, 105.65),
];

TideZone tideZoneAt(double lat, double lon) {
  if (_inside(_south, lat, lon)) return TideZone.south;
  if (_inside(_north, lat, lon)) return TideZone.north;
  return TideZone.other;
}

/// Even-odd ray test.
bool _inside(List<(double, double)> poly, double lat, double lon) {
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final (yi, xi) = poly[i];
    final (yj, xj) = poly[j];
    if ((yi > lat) != (yj > lat) && lon < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
      inside = !inside;
    }
  }
  return inside;
}
