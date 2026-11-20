/// One forecast hour (Open-Meteo, instant at [timeUtc] except [rainMm],
/// which is the total of the hour before). Every value may be missing:
/// old cached answers lack the newer fields and the model leaves gaps.
class WxHour {
  const WxHour({
    required this.timeUtc,
    this.tempC,
    this.feelsC,
    this.humidityPct,
    this.rainMm,
    this.rainProbPct,
    this.code,
    this.pressureHpa,
    this.windKmh,
    this.gustKmh,
    this.windFromDeg,
    this.uv,
    this.visibilityM,
    this.isDay,
  });

  final DateTime timeUtc;
  final double? tempC;

  /// Apparent ("feels like") temperature.
  final double? feelsC;
  final double? humidityPct;
  final double? rainMm;
  final double? rainProbPct;

  /// WMO weather code.
  final int? code;
  final double? pressureHpa;
  final double? windKmh;
  final double? gustKmh;

  /// Direction the wind blows FROM, degrees clockwise from north.
  final double? windFromDeg;
  final double? uv;
  final double? visibilityM;
  final bool? isDay;
}

/// Index of the hour slot containing [nowUtc] (hours are on the hour, sorted);
/// -1 when [hours] does not cover it.
int hourIndexAt(List<WxHour> hours, DateTime nowUtc) {
  final slot = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, nowUtc.hour);
  for (var i = 0; i < hours.length; i++) {
    if (hours[i].timeUtc == slot) return i;
  }
  return -1;
}
