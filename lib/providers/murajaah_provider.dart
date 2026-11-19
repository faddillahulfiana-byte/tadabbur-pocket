import 'package:flutter/material.dart';
import '../core/constants/supabase_config.dart';
import '../core/services/supabase_service.dart';
import '../models/murajaah_log_model.dart';

class MurajaahProvider extends ChangeNotifier {
  List<MurajaahLog> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MurajaahLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalSessions => _logs.length;

  int get lancarCount =>
      _logs.where((l) => l.fluencyLevel == 'lancar').length;

  int get perluDiulangCount =>
      _logs.where((l) => l.fluencyLevel == 'perlu_diulang').length;

  int get belumLancarCount =>
      _logs.where((l) => l.fluencyLevel == 'belum_lancar').length;

  /// Memuat riwayat murajaah milik pengguna
  Future<void> fetchLogs() async {
    final user = SupabaseService.currentUser;
    if (user == null || !SupabaseConfig.isConfigured) {
      _logs = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<dynamic> response = await SupabaseService.client
          .from('murajaah_logs')
          .select('*, surahs(*)')
          .eq('user_id', user.id)
          .order('murajaah_at', ascending: false);

      _logs = response.map((data) => MurajaahLog.fromMap(data)).toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat murajaah: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Menambahkan sesi murajaah baru
  Future<bool> addLog({
    required int surahId,
    required String verseRange,
    required bool isFullSurah,
    required String fluencyLevel,
    String? notes,
    required DateTime murajaahAt,
  }) async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      _errorMessage = 'Silakan masuk untuk mencatat murajaah.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await SupabaseService.client.from('murajaah_logs').insert({
        'user_id': user.id,
        'surah_id': surahId,
        'verse_range': isFullSurah ? '1 - Selesai' : verseRange,
        'is_full_surah': isFullSurah,
        'fluency_level': fluencyLevel,
        'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
        'murajaah_at': murajaahAt.toIso8601String(),
      });

      // Muat ulang daftar setelah penambahan
      await fetchLogs();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menyimpan catatan: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Menghapus log murajaah
  Future<bool> deleteLog(String logId) async {
    try {
      await SupabaseService.client
          .from('murajaah_logs')
          .delete()
          .eq('id', logId);

      _logs.removeWhere((l) => l.id == logId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus log: $e';
      notifyListeners();
      return false;
    }
  }
}
