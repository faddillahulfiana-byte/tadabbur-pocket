import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profile = authProvider.userProfile;
    final isGuest = authProvider.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Pengaturan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu Profil Pengguna
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.primaryLight.withOpacity(0.15),
                      child: Icon(
                        isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                        size: 34,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.displayName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isGuest
                                ? 'Pengguna Tamu (Lokal)'
                                : (authProvider.currentUser?.email ?? ''),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: isGuest
                                  ? AppTheme.warning.withOpacity(0.12)
                                  : AppTheme.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isGuest ? 'Mode Tamu' : 'Tersinkron Cloud',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isGuest ? AppTheme.warning : AppTheme.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (isGuest) ...[
              Card(
                color: const Color(0xFFF1F8F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFD2E8DE)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.cloud_sync_rounded, color: AppTheme.primary),
                          SizedBox(width: 10),
                          Text(
                            'Cadangkan Data Hafalan Anda',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Masuk atau buat akun baru agar catatan murajaah dan quote favorit tidak hilang saat berganti perangkat.',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: const Text('Masuk / Daftar Akun'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Pengaturan Pengingat Murajaah
            const Text(
              'Pengingat & Alarm',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Aktifkan Notifikasi Harian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Pengingat otomatis di ponsel Anda untuk murajaah', style: TextStyle(fontSize: 12)),
                    value: profile?.isReminderEnabled ?? true,
                    activeColor: AppTheme.primary,
                    onChanged: isGuest
                        ? (val) {
                            AppHelpers.requireLogin(context, actionMessage: 'mengatur jadwal pengingat');
                          }
                        : (val) async {
                            final hour = profile?.reminderHour ?? 5;
                            final min = profile?.reminderMinute ?? 30;
                            await authProvider.updateReminder(hour: hour, minute: min, isEnabled: val);
                          },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.access_time_rounded, color: AppTheme.primary),
                    title: const Text('Waktu Pengingat', style: TextStyle(fontSize: 14)),
                    trailing: Text(
                      '${profile?.formattedReminderTime ?? '05:30'} WIB',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                    onTap: isGuest
                        ? () {
                            AppHelpers.requireLogin(context, actionMessage: 'mengubah waktu pengingat');
                          }
                        : () async {
                            final current = TimeOfDay(
                              hour: profile?.reminderHour ?? 5,
                              minute: profile?.reminderMinute ?? 30,
                            );
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: current,
                            );
                            if (picked != null) {
                              final ok = await authProvider.updateReminder(
                                hour: picked.hour,
                                minute: picked.minute,
                                isEnabled: profile?.isReminderEnabled ?? true,
                              );
                              if (context.mounted && ok) {
                                AppHelpers.showSnackBar(context, 'Waktu pengingat diperbarui');
                              }
                            }
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tentang Aplikasi
            const Text(
              'Tentang Aplikasi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.auto_stories_rounded, color: AppTheme.primary),
                    title: Text('Tadabbur Pocket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text('Aplikasi Menjaga Hafalan & Memahami Makna Al-Qur''an', style: TextStyle(fontSize: 12)),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.info_outline_rounded, color: AppTheme.primary),
                    title: Text('Versi Aplikasi', style: TextStyle(fontSize: 14)),
                    trailing: Text('1.0.0 (Release APK)', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.storage_rounded, color: AppTheme.primary),
                    title: Text('Database Backend', style: TextStyle(fontSize: 14)),
                    trailing: Text('Supabase Cloud', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Keluar (jika login)
            if (!isGuest) ...[
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Keluar dari Akun?'),
                      content: const Text(
                        'Anda akan kembali ke Mode Tamu. Data yang tersimpan di cloud tetap aman.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
                          child: const Text('Keluar'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await authProvider.signOut();
                    if (context.mounted) {
                      AppHelpers.showSnackBar(context, 'Berhasil keluar');
                    }
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
                label: const Text('Keluar dari Akun', style: TextStyle(color: AppTheme.danger)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.danger),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
