/// Whether this build should run against the shared Supabase backend
/// instead of the local Drift/SQLite database. A compile-time switch (not a
/// runtime setting) on purpose — a store's data never silently jumps
/// between "local file" and "shared cloud database" mid-session.
///
/// Build with `--dart-define=UNOPOS_USE_SUPABASE=true --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
/// once a Supabase project exists (see SETUP_GUIDE.md). Until then this is
/// false and the app behaves exactly as it always has, fully offline.
const bool kUseSupabaseBackend = bool.fromEnvironment('UNOPOS_USE_SUPABASE');

class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Store ID + Password is the product's login UX, but Supabase Auth (like
  /// most backends) is email/password shaped. This maps a store's login id
  /// to a synthetic, never-emailed address purely so `signUp`/
  /// `signInWithPassword` have something to key off — the store never sees
  /// or types this address anywhere.
  static String syntheticEmailFor(String storeLoginId) {
    final normalized = storeLoginId.trim().toLowerCase();
    return '$normalized@stores.unopos.internal';
  }
}
