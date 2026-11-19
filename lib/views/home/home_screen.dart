import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../models/quote_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/murajaah_provider.dart';
import '../../providers/quote_provider.dart';
import '../auth/login_screen.dart';
import '../murajaah/add_murajaah_dialog.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final quoteProvider = context.watch<QuoteProvider>();
    final murajaahProvider = context.watch<MurajaahProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book_rounded, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Tadabbur Pocket'),
          ],
        ),
        actions: [
          if (authProvider.isGuest)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Masuk'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  backgroundColor: AppTheme.surfaceMuted,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await quoteProvider.fetchQuotes();
          if (authProvider.isAuthenticated) {
            await murajaahProvider.fetchLogs();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Salam Pengguna
              _buildGreetingSection(context, authProvider),
              const SizedBox(height: 20),

              // Kartu Quote Hari Ini (Acak + Favorit + Share)
              _buildQuoteCard(context, quoteProvider, authProvider),
              const SizedBox(height: 24),

              // Tombol Aksi Cepat
              const Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context, authProvider),
              const SizedBox(height: 24),

              // Ringkasan Murajaah Terakhir
              _buildRecentMurajaahCard(context, murajaahProvider, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF094E3E), Color(0xFF148F74)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assalamu''alaikum,',
                  style: TextStyle(
                    color: Color(0xFFD2E8E0),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  authProvider.isGuest
                      ? 'Mode Tamu (Masuk untuk menyimpan riwayat)'
                      : 'Semoga harimu dipenuhi keberkahan Al-Qur''an.',
                  style: const TextStyle(
                    color: Color(0xFFE2EFEA),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context,
    QuoteProvider quoteProvider,
    AuthProvider authProvider,
  ) {
    final quote = quoteProvider.currentRandomQuote;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD8E5DF), width: 1.2),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.format_quote_rounded, color: AppTheme.accent, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      quote?.isQuranVerse == true ? 'Ayat Pilihan' : 'Inspirasi Islami',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quote?.topic ?? 'Umum',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (quoteProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (quote == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Belum ada quote yang dimuat.'),
                ),
              )
            else ...[
              if (quote.arabicText != null && quote.arabicText!.isNotEmpty) ...[
                Text(
                  quote.arabicText!,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.8,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                '"${quote.content}"',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppTheme.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '— ${quote.sourceRef}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const Divider(height: 28, color: Color(0xFFEEF3F0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => quoteProvider.nextRandomQuote(),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Acak Lagi', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Bagikan',
                        icon: const Icon(Icons.share_outlined, size: 20, color: AppTheme.textSecondary),
                        onPressed: () {
                          final text = '${quote.arabicText != null ? "${quote.arabicText}\n\n" : ""}"${quote.content}"\n\n— ${quote.sourceRef}\n(Dibagikan dari Tadabbur Pocket)';
                          Share.share(text);
                        },
                      ),
                      IconButton(
                        tooltip: quote.isFavorite ? 'Hapus Favorit' : 'Simpan Favorit',
                        icon: Icon(
                          quote.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: quote.isFavorite ? Colors.red : AppTheme.textSecondary,
                          size: 22,
                        ),
                        onPressed: () async {
                          if (authProvider.isGuest) {
                            await AppHelpers.requireLogin(
                              context,
                              actionMessage: 'menyimpan quote ini ke daftar favorit Anda',
                            );
                            return;
                          }
                          final success = await quoteProvider.toggleFavorite(quote);
                          if (context.mounted && success) {
                            AppHelpers.showSnackBar(
                              context,
                              quote.isFavorite ? 'Disimpan ke Favorit' : 'Dihapus dari Favorit',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthProvider authProvider) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              if (authProvider.isGuest) {
                final proceed = await AppHelpers.requireLogin(
                  context,
                  actionMessage: 'mencatat riwayat murajaah Anda',
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
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.add_task_rounded, color: AppTheme.primary, size: 28),
                  SizedBox(height: 10),
                  Text(
                    'Catat Murajaah',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Simpan progres hafalan',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () {
              onNavigateTab?.call(1); // Pindah ke Tab 1 (Tadabbur Juz 30)
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentLight.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.menu_book_rounded, color: Color(0xFFB08810), size: 28),
                  SizedBox(height: 10),
                  Text(
                    'Tadabbur Juz 30',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF634D09),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Baca 37 surah ringkas',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMurajaahCard(
    BuildContext context,
    MurajaahProvider murajaahProvider,
    AuthProvider authProvider,
  ) {
    if (authProvider.isGuest) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppTheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Riwayat Murajaah Tersimpan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Masuk akun untuk melihat statistik dan riwayat hafalan Anda di sini.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final logs = murajaahProvider.logs;
    if (logs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Icon(Icons.history_rounded, size: 36, color: AppTheme.textMuted),
              const SizedBox(height: 8),
              const Text(
                'Belum Ada Catatan Murajaah',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tekan tombol Catat Murajaah untuk menyimpan capaian hafalan hari ini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final lastLog = logs.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Murajaah Terakhir',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                TextButton(
                  onPressed: () => onNavigateTab?.call(2), // Tab Murajaah
                  child: const Text('Lihat Semua', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    lastLog.surah?.surahNumber.toString() ?? '#',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastLog.surah?.latinName ?? 'Surah #${lastLog.surahId}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Ayat: ${lastLog.verseRange} • ${lastLog.fluencyLabel}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppHelpers.formatShortDate(lastLog.murajaahAt),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
