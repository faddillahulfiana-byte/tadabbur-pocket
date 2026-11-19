import 'package:flutter/material.dart';
import '../core/constants/supabase_config.dart';
import '../core/services/supabase_service.dart';
import '../models/surah_model.dart';

class SurahProvider extends ChangeNotifier {
  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<Surah> get surahs => _filteredSurahs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  SurahProvider() {
    fetchSurahs();
  }

  /// Mengambil daftar 37 Surah Juz 30 dari Supabase
  Future<void> fetchSurahs() async {
    if (!SupabaseConfig.isConfigured) {
      _errorMessage = 'Supabase belum terkonfigurasi. Pastikan --dart-define telah disetel.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<dynamic> response = await SupabaseService.client
          .from('surahs')
          .select()
          .order('surah_number', ascending: true);

      _surahs = response.map((data) => Surah.fromMap(data)).toList();
      _applySearch();
    } catch (e) {
      _errorMessage = 'Gagal memuat data surah: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Pencarian Surah berdasarkan Nama Latin, Arti, atau Nomor
  void searchSurahs(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredSurahs = List.from(_surahs);
    } else {
      _filteredSurahs = _surahs.where((s) {
        final matchLatin = s.latinName.toLowerCase().contains(_searchQuery);
        final matchMeaning = s.meaning.toLowerCase().contains(_searchQuery);
        final matchNumber = s.surahNumber.toString() == _searchQuery;
        return matchLatin || matchMeaning || matchNumber;
      }).toList();
    }
  }

  /// Mencari surah berdasarkan ID
  Surah? getSurahById(int id) {
    try {
      return _surahs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
