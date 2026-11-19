import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static bool get isAuthenticated => currentUser != null;

  /// Inisialisasi Supabase SDK
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      if (kDebugMode) {
        print('⚠️ Peringatan: SupabaseConfig.url atau anonKey belum diisi.');
        print('Gunakan --dart-define=SUPABASE_URL=... dan --dart-define=SUPABASE_ANON_KEY=...');
      }
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      if (kDebugMode) {
        print('✅ Supabase berhasil diinisialisasi: ${SupabaseConfig.url}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Gagal inisialisasi Supabase: $e');
      }
    }
  }
}
