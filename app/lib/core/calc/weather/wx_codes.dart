/// Plain-language classes for forecast numbers: sky from the WMO code, wind
/// force (Beaufort, as Vietnamese forecasts say "cấp 6"), compass point, UV.
library;

/// What the sky looks like, from Open-Meteo's WMO weather code.
enum WxSky {
  clear,
  mainlyClear,
  partlyCloudy,
  overcast,
  fog,
  drizzle,
  rainLight,
  rainModerate,
  rainHeavy,
  showersLight,
  showers,
  showersHeavy,
  snow,
  thunderstorm,
  thunderstormHail,
}

/// WMO 4677 subset used by Open-Meteo (documented on its forecast API page).
/// Unknown codes → null, so the UI shows no guess.
WxSky? skyOf(int? code) => switch (code) {
  0 => WxSky.clear,
  1 => WxSky.mainlyClear,
  2 => WxSky.partlyCloudy,
  3 => WxSky.overcast,
  45 || 48 => WxSky.fog,
  51 || 53 || 55 || 56 || 57 => WxSky.drizzle,
  61 || 66 => WxSky.rainLight,
  63 => WxSky.rainModerate,
  65 || 67 => WxSky.rainHeavy,
  71 || 73 || 75 || 77 || 85 || 86 => WxSky.snow,
  80 => WxSky.showersLight,
  81 => WxSky.showers,
  82 => WxSky.showersHeavy,
  95 => WxSky.thunderstorm,
  96 || 99 => WxSky.thunderstormHail,
  _ => null,
};

/// Thunderstorm codes: lightning over open water is the top danger.
bool isStormCode(int? code) => code == 95 || code == 96 || code == 99;

/// Fog codes (45 fog, 48 depositing rime fog).
bool isFogCode(int? code) => code == 45 || code == 48;

/// Beaufort force from a 10 m wind speed. Upper bounds in m/s of forces 0–11
/// (WMO scale, as Vietnam's KTTV states it: force 6 = 10.8–13.8 m/s ≈ 39–50
/// km/h). Anything at or above force 11's bound is force 12.
const List<double> beaufortUpperMs = [
  0.3,
  1.6,
  3.4,
  5.5,
  8,
  10.8,
  13.9,
  17.2,
  20.8,
  24.5,
  28.5,
  32.7,
];

int beaufort(double kmh) {
  final ms = kmh / 3.6;
  for (var f = 0; f < beaufortUpperMs.length; f++) {
    if (ms < beaufortUpperMs[f]) return f;
  }
  return 12;
}

/// Eight compass points, the way Vietnamese forecasts name winds ("gió Đông Bắc").
enum Compass { n, ne, e, se, s, sw, w, nw }

/// Compass point a direction (degrees from north) falls in; each covers 45°.
Compass compassOf(double deg) {
  final d = deg % 360;
  final i = ((d + 22.5) ~/ 45) % 8;
  return Compass.values[i];
}

/// WHO UV index bands.
enum UvLevel { low, moderate, high, veryHigh, extreme }

UvLevel uvLevel(double uv) => switch (uv) {
  < 3 => UvLevel.low,
  < 6 => UvLevel.moderate,
  < 8 => UvLevel.high,
  < 11 => UvLevel.veryHigh,
  _ => UvLevel.extreme,
};
