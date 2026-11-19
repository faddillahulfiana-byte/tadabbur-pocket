import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/supabase_config.dart';
import '../core/services/supabase_service.dart';
import '../models/quote_model.dart';

class QuoteProvider extends ChangeNotifier {
  List<Quote> _allQuotes = [];
  Set<String> _favoriteQuoteIds = {};
  Quote? _currentRandomQuote;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'all'; // 'all' | 'quran_verse' | 'motivation'

  List<Quote> get allQuotes => _allQuotes;
  Quote? get currentRandomQuote => _currentRandomQuote;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  List<Quote> get filteredQuotes {
    if (_selectedCategory == 'all') return _allQuotes;
    return _allQuotes.where((q) => q.quoteType == _selectedCategory).toList();
  }

  List<Quote> get favoriteQuotes {
    return _allQuotes.where((q) => q.isFavorite).toList();
  }

  QuoteProvider() {
    fetchQuotes();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Mengambil semua quote dan status favorit pengguna dari Supabase
  Future<void> fetchQuotes() async {
    if (!SupabaseConfig.isConfigured) {
      _errorMessage = 'Supabase belum terkonfigurasi. Pastikan --dart-define telah disetel.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Ambil daftar quote
      final List<dynamic> response =
          await SupabaseService.client.from('quotes').select().order('created_at');

      // 2. Ambil daftar favorit jika sudah login
      await _fetchFavoriteIds();

      _allQuotes = response.map((data) {
        final id = data['id']?.toString() ?? '';
        final isFav = _favoriteQuoteIds.contains(id);
        return Quote.fromMap(data, isFav: isFav);
      }).toList();

      // Pilih satu quote acak untuk beranda
      nextRandomQuote();
    } catch (e) {
      _errorMessage = 'Gagal memuat quote: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchFavoriteIds() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      _favoriteQuoteIds = {};
      return;
    }

    try {
      final List<dynamic> favs = await SupabaseService.client
          .from('user_favorite_quotes')
          .select('quote_id')
          .eq('user_id', user.id);

      _favoriteQuoteIds = favs.map((f) => f['quote_id'].toString()).toSet();
    } catch (_) {
      _favoriteQuoteIds = {};
    }
  }

  /// Memilih quote acak berikutnya
  void nextRandomQuote() {
    if (_allQuotes.isEmpty) {
      _currentRandomQuote = null;
      notifyListeners();
      return;
    }

    final random = Random();
    int randomIndex = random.nextInt(_allQuotes.length);
    _currentRandomQuote = _allQuotes[randomIndex];
    notifyListeners();
  }

  /// Menyimpan atau menghapus quote dari daftar favorit
  Future<bool> toggleFavorite(Quote quote) async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      return false; // Memerlukan login
    }

    final willFavorite = !quote.isFavorite;

    // Optimistic UI update
    quote.isFavorite = willFavorite;
    if (willFavorite) {
      _favoriteQuoteIds.add(quote.id);
    } else {
      _favoriteQuoteIds.remove(quote.id);
    }
    notifyListeners();

    try {
      if (willFavorite) {
        await SupabaseService.client.from('user_favorite_quotes').insert({
          'user_id': user.id,
          'quote_id': quote.id,
        });
      } else {
        await SupabaseService.client
            .from('user_favorite_quotes')
            .delete()
            .eq('user_id', user.id)
            .eq('quote_id', quote.id);
      }
      return true;
    } catch (e) {
      // Rollback jika gagal
      quote.isFavorite = !willFavorite;
      if (willFavorite) {
        _favoriteQuoteIds.remove(quote.id);
      } else {
        _favoriteQuoteIds.add(quote.id);
      }
      notifyListeners();
      return false;
    }
  }
}
