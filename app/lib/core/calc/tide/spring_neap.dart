/// Tidal range class of a day compared with the 29-day mean (PROJECT.md 9.1, 9.3).
enum SpringNeap {
  /// Range ≥ 120% of mean ("nước rong").
  spring,

  /// Between neap and spring.
  normal,

  /// Range ≤ 80% of mean ("nước kém").
  neap,
}
