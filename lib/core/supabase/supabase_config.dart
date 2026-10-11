/// Whether this build should run against the shared Supabase backend
/// instead of the local Drift/SQLite database. A compile-time switch (not a
/// runtime setting) on purpose — a store's data never silently jumps
/// between "local file" and "shared cloud database" mid-session.
///
/// Defaults to the shared cloud backend so every device (Windows, Android)
/// sees the same store data with a plain `flutter build`. Build with
/// `--dart-define=UNOPOS_USE_SUPABASE=false` for the old fully-offline,
/// single-device mode.
const bool kUseSupabaseBackend = bool.fromEnvironment('UNOPOS_USE_SUPABASE', defaultValue: true);

class SupabaseConfig {
  const SupabaseConfig._();

  // The publishable key is designed to ship inside client apps — data access
  // is guarded by the RLS policies in supabase/migrations, not by this key.
  // Override either with --dart-define to point a build at another project.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ydfhhvkzasqvgqlsuxdh.supabase.co',
  );
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_O0UzNCprH8N2c0FH4KTMaQ_O7DbUP59',
  );

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
