import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rivertide/app.dart';
import 'package:rivertide/core/config/env.dart';
import 'package:rivertide/core/errors/retry_policy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Community spots (P2-19) only when a Supabase project is configured.
  if (Env.communityEnabled) {
    await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseAnonKey);
  }
  runApp(const ProviderScope(retry: providerRetry, child: RiverTideApp()));
}
