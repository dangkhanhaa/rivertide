/// Coarse bounding box of Vietnam including offshore islands
/// (Hoàng Sa, Trường Sa, Phú Quốc, Côn Đảo). It also covers parts of
/// neighbouring countries and sea, so use it only as a sanity check on
/// input coordinates, never as a border test.
const double vnMinLat = 8;
const double vnMaxLat = 23.5;
const double vnMinLon = 102;
const double vnMaxLon = 117.5;

/// True when (lat, lon) lies inside the coarse Vietnam bbox (inclusive).
bool isInVietnamBounds(double lat, double lon) =>
    lat >= vnMinLat && lat <= vnMaxLat && lon >= vnMinLon && lon <= vnMaxLon;
