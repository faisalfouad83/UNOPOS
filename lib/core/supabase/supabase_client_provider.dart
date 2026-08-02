import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// Call once, before `runApp`, only when [kUseSupabaseBackend] is true. Safe
/// to call unconditionally otherwise too — it's cheap and idempotent — but
/// callers should still guard it so a purely-local build never needs
/// `SUPABASE_URL`/`SUPABASE_ANON_KEY` to be defined at all.
Future<void> initSupabase() async {
  await Supabase.initialize(url: SupabaseConfig.url, publishableKey: SupabaseConfig.anonKey);
}

/// The shared Supabase client. Only ever read when [kUseSupabaseBackend] is
/// true — reading this in local-only mode throws, since `initSupabase()`
/// was never called and no client exists.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
