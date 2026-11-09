import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/app.dart';
import 'package:rivertide/core/errors/retry_policy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(retry: providerRetry, child: RiverTideApp()));
}
