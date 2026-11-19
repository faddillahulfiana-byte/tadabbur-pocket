import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../models/murajaah_log_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/murajaah_provider.dart';
import 'add_murajaah_dialog.dart';

class MurajaahScreen extends StatelessWidget {
  const MurajaahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final murajaahProvider = context.watch<MurajaahProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan & Pengingat Murajaah'),
        actions: [
          if (authProvider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Muat Ulang',
              onPressed: () => murajaahProvider.fetchLogs(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (authProvider.isGuest) {
            final proceed = await AppHelpers.requireLogin(
              context,
              actionMessage: 'mencatat riwayat hafalan murajaah Anda',
            );
            if (!proceed) return;
          }

          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => const AddMurajaahDialog(),
            );
          }
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Catat Sesi', style: TextStyle(color: Colors.white)),
      ),
      body: authProvider.isGuest
          ? _buildGuestView(context)
          : RefreshIndicator(
              onRefresh: () => murajaahProvider.fetchLogs(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Pengingat Harian Card
                    _buildReminderCard(context, authProvider),
                    const SizedBox(height: 16),

                    // Ringkasan Statistik
                    _buildStatOverview(murajaahProvider),
                    const SizedBox(height: 20),

                    // Daftar Riwayat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Sesi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${murajaahProvider.totalSessions} sesi tercatat',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (murajaahProvider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (murajaahProvider.logs.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: murajaahProvider.logs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, index) {
                          final log = murajaahProvider.logs[index];
                          return _buildLogCard(context, log, murajaahProvider);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_clock_outlined,
                size: 56,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fitur Khusus Akun Terdaftar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masuk dengan email Anda untuk mencatat hafalan, memantau grafik kelancaran, dan menyetel alarm pengingat harian.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                AppHelpers.requireLogin(
                  context,
                  actionMessage: 'mengakses catatan dan pengingat murajaah',
                );
              },
              child: const Text('Masuk / Daftar Akun'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, AuthProvider authProvider) {
    final profile = authProvider.userProfile;
    final isEnabled = profile?.isReminderEnabled ?? true;
    final timeStr = profile?.formattedReminderTime ?? '05:30';

    return Card(
      color: const Color(0xFFF1F7F4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD4E5DC)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm_rounded, color: AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengingat Murajaah',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEnabled
                        ? 'Setiap hari pukul $timeStr WIB'
                        : 'Pengingat dimatikan',
                    style: TextStyle(
                      fontSize: 12,
                      color: isEnabled ? AppTheme.primary : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                final initialTime = TimeOfDay(
                  hour: profile?.reminderHour ?? 5,
                  minute: profile?.reminderMinute ?? 30,
                );

                final picked = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                );

                if (picked != null) {
                  final ok = await authProvider.updateReminder(
                    hour: picked.hour,
                    minute: picked.minute,
                    isEnabled: true,
                  );
                  if (context.mounted && ok) {
                    AppHelpers.showSnackBar(
                      context,
                      'Pengingat disetel ke pukul ${picked.format(context)}',
                    );
                  }
                }
              },
              child: const Text('Ubah Jam'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatOverview(MurajaahProvider provider) {
    return Row(
      children: [
        _buildStatBox('Total', '${provider.totalSessions}', AppTheme.primary),
        const SizedBox(width: 8),
        _buildStatBox('Lancar', '${provider.lancarCount}', AppTheme.success),
        const SizedBox(width: 8),
        _buildStatBox('Diulang', '${provider.perluDiulangCount}', AppTheme.warning),
        const SizedBox(width: 8),
        _buildStatBox('Belum', '${provider.belumLancarCount}', AppTheme.danger),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.85),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.menu_book_outlined, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Catatan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mulai rutinitas hafalan Anda hari ini dengan menekan tombol Catat Sesi di bawah.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(
    BuildContext context,
    MurajaahLog log,
    MurajaahProvider murajaahProvider,
  ) {
    Color badgeColor;
    IconData badgeIcon;
    switch (log.fluencyLevel) {
      case 'lancar':
        badgeColor = AppTheme.success;
        badgeIcon = Icons.check_circle_outline_rounded;
        break;
      case 'perlu_diulang':
        badgeColor = AppTheme.warning;
        badgeIcon = Icons.replay_rounded;
        break;
      case 'belum_lancar':
      default:
        badgeColor = AppTheme.danger;
        badgeIcon = Icons.error_outline_rounded;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        log.surah != null ? '${log.surah!.surahNumber}' : '#',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      log.surah?.latinName ?? 'Surah #${log.surahId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18),
                  padding: EdgeInsets.zero,
                  onSelected: (val) async {
                    if (val == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Hapus Catatan?'),
                          content: const Text(
                            'Catatan sesi murajaah ini akan dihapus permanen dari akun Anda.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final ok = await murajaahProvider.deleteLog(log.id);
                        if (context.mounted && ok) {
                          AppHelpers.showSnackBar(context, 'Catatan berhasil dihapus');
                        }
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 18),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: AppTheme.danger)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.format_list_numbered_rounded, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Ayat: ${log.verseRange}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 12),
                Icon(badgeIcon, size: 14, color: badgeColor),
                const SizedBox(width: 4),
                Text(
                  log.fluencyLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.notes!,
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                AppHelpers.formatDate(log.murajaahAt),
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
