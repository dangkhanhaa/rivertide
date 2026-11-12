import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/core/db/app_database.dart';

const _key = 'alert_places';
const _optionsKey = 'alert_options';

/// Saved places with tide alarms on (stored as a JSON list in settings).
class AlertPlaces extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final raw = await ref.watch(appDatabaseProvider).readSetting(_key);
    if (raw == null) return {};
    try {
      final list = jsonDecode(raw);
      return list is List ? list.whereType<String>().toSet() : {};
    } on FormatException {
      return {};
    }
  }

  Future<void> setOn(String id, {required bool on}) async {
    final next = {...state.value ?? const <String>{}};
    if (on) {
      next.add(id);
    } else {
      next.remove(id);
    }
    state = AsyncData(next);
    await ref.read(appDatabaseProvider).writeSetting(_key, jsonEncode(next.toList()));
  }
}

final AsyncNotifierProvider<AlertPlaces, Set<String>> alertPlacesProvider = AsyncNotifierProvider(
  AlertPlaces.new,
);

/// Lead times the user can pick (P2-22).
const List<int> alertLeadChoicesMin = [15, 30, 60];

/// What rings and how early (P2-22). Defaults = the behaviour before options.
class AlertOptions {
  const AlertOptions({this.golden = true, this.tides = true, this.leadMinutes = 30});

  /// Read from settings JSON; unknown or out-of-range values fall back to defaults.
  factory AlertOptions.fromJson(Object? json) {
    if (json is! Map<String, Object?>) return const AlertOptions();
    final lead = json['lead'];
    return AlertOptions(
      golden: json['golden'] != false,
      tides: json['tides'] != false,
      leadMinutes: lead is int && alertLeadChoicesMin.contains(lead) ? lead : 30,
    );
  }

  final bool golden;
  final bool tides;
  final int leadMinutes;

  Duration get lead => Duration(minutes: leadMinutes);

  Map<String, Object> toJson() => {'golden': golden, 'tides': tides, 'lead': leadMinutes};

  AlertOptions copyWith({bool? golden, bool? tides, int? leadMinutes}) => AlertOptions(
    golden: golden ?? this.golden,
    tides: tides ?? this.tides,
    leadMinutes: leadMinutes ?? this.leadMinutes,
  );
}

class AlertOptionsNotifier extends AsyncNotifier<AlertOptions> {
  @override
  Future<AlertOptions> build() async {
    final raw = await ref.watch(appDatabaseProvider).readSetting(_optionsKey);
    if (raw == null) return const AlertOptions();
    try {
      return AlertOptions.fromJson(jsonDecode(raw));
    } on FormatException {
      return const AlertOptions();
    }
  }

  Future<void> save(AlertOptions options) async {
    state = AsyncData(options);
    await ref.read(appDatabaseProvider).writeSetting(_optionsKey, jsonEncode(options.toJson()));
  }
}

final AsyncNotifierProvider<AlertOptionsNotifier, AlertOptions> alertOptionsProvider =
    AsyncNotifierProvider(AlertOptionsNotifier.new);
