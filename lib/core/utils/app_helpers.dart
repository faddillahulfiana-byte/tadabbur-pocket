import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../views/auth/login_screen.dart';
import '../constants/app_theme.dart';

class AppHelpers {
  /// Format tanggal Indonesia
  static String formatDate(DateTime dateTime) {
    try {
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (_) {
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    }
  }

  /// Format tanggal singkat
  static String formatShortDate(DateTime dateTime) {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  /// Menampilkan pesan toast / snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.danger : AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Modal pelindung aksi pengguna Guest (belum login)
  static Future<bool> requireLogin(
    BuildContext context, {
    required String actionMessage,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppTheme.surface,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.lock_person_outlined,
                  size: 48,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Perlu Masuk Akun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Untuk $actionMessage, silakan masuk dengan akun Anda agar data tersimpan aman di cloud.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Nanti Saja'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx, true);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text('Masuk / Daftar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }
}
