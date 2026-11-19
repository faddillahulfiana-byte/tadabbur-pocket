/// Konfigurasi koneksi ke Supabase via --dart-define
/// Supabase URL dan Anon Key disuntikkan saat build (misalnya di GitHub Secrets)
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Mengecek apakah kredensial sudah dikonfigurasi
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
