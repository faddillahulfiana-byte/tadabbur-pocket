import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_config.dart';
import '../core/services/notification_service.dart';
import '../core/services/supabase_service.dart';
import '../models/user_profile_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _currentUser == null;

  String get displayName {
    if (_userProfile?.fullName != null && _userProfile!.fullName!.isNotEmpty) {
      return _userProfile!.fullName!;
    }
    if (_currentUser?.email != null) {
      return _currentUser!.email!.split('@').first;
    }
    return 'Tamu';
  }

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    if (!SupabaseConfig.isConfigured) return;

    try {
      _currentUser = SupabaseService.currentUser;
      if (_currentUser != null) {
        loadUserProfile();
      }

      SupabaseService.client.auth.onAuthStateChange.listen((data) {
        _currentUser = data.session?.user;
        if (_currentUser != null) {
          loadUserProfile();
        } else {
          _userProfile = null;
        }
        notifyListeners();
      });
    } catch (_) {}
  }

  /// Memuat profil pengguna dan preferensi pengingat
  Future<void> loadUserProfile() async {
    if (_currentUser == null) return;

    try {
      final res = await SupabaseService.client
          .from('user_profiles')
          .select()
          .eq('user_id', _currentUser!.id)
          .maybeSingle();

      if (res != null) {
        _userProfile = UserProfile.fromMap(res);
        // Sinkronisasi jadwal pengingat ke notifikasi lokal HP jika aktif
        if (_userProfile!.isReminderEnabled) {
          NotificationService().scheduleDailyMurajaahReminder(
            hour: _userProfile!.reminderHour,
            minute: _userProfile!.reminderMinute,
          );
        }
      } else {
        // Jika belum ada record profile, buatkan secara aman
        _userProfile = UserProfile(userId: _currentUser!.id);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error memuat profil: $e');
    }
  }

  /// Masuk dengan Email dan Kata Sandi
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      _errorMessage = 'Supabase belum terkonfigurasi via --dart-define.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      _currentUser = response.user;
      await loadUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat masuk: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Mendaftar Akun Baru
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      _errorMessage = 'Supabase belum terkonfigurasi via --dart-define.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );

      _currentUser = response.user;
      if (_currentUser != null) {
        await loadUserProfile();
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan pendaftaran: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Perbarui Pengingat Murajaah
  Future<bool> updateReminder({
    required int hour,
    required int minute,
    required bool isEnabled,
  }) async {
    if (_currentUser == null) return false;

    final formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';

    try {
      await SupabaseService.client.from('user_profiles').upsert({
        'user_id': _currentUser!.id,
        'reminder_time': formattedTime,
        'is_reminder_enabled': isEnabled,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _userProfile = UserProfile(
        userId: _currentUser!.id,
        fullName: _userProfile?.fullName,
        reminderTime: formattedTime,
        isReminderEnabled: isEnabled,
      );

      if (isEnabled) {
        await NotificationService().requestPermissions();
        await NotificationService().scheduleDailyMurajaahReminder(
          hour: hour,
          minute: minute,
        );
      } else {
        await NotificationService().cancelMurajaahReminder();
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error update reminder: $e');
      return false;
    }
  }

  /// Keluar (Sign Out)
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.client.auth.signOut();
      _currentUser = null;
      _userProfile = null;
    } catch (e) {
      debugPrint('Error sign out: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
