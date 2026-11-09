/// Solunar period classification (PROJECT.md 9.5).
enum SolunarKind {
  /// ±60 min around moon upper/lower transit.
  major,

  /// ±30 min around moonrise/moonset.
  minor,

  /// Outside any period.
  none,
}
