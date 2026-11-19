import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../models/surah_model.dart';
import '../../providers/auth_provider.dart';
import '../murajaah/add_murajaah_dialog.dart';

class SurahDetailScreen extends StatelessWidget {
  final Surah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Surah ${surah.latinName}'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () async {
              if (authProvider.isGuest) {
                final proceed = await AppHelpers.requireLogin(
                  context,
                  actionMessage: 'mencatat riwayat murajaah Surah ${surah.latinName}',
                );
                if (!proceed) return;
              }

              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (_) => AddMurajaahDialog(initialSurahId: surah.id),
                );
              }
            },
            icon: const Icon(Icons.bookmark_add_rounded),
            label: Text('Catat Murajaah Surah ${surah.latinName}'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Identitas Surah
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF094E3E), Color(0xFF148F74)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    surah.arabicName,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    surah.latinName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Arti: "${surah.meaning}"',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFD3ECE3),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Surah ke-${surah.surahNumber} • ${surah.totalVerses} Ayat • ${surah.revelationType}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tema Inti Surah
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accent, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Pesan Inti Surah',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      surah.mainTheme,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Ayat Kunci
            if (surah.keyVerse != null && surah.keyVerse!.isNotEmpty) ...[
              Card(
                color: const Color(0xFFF9FBF0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2EAC7), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star_rounded, color: AppTheme.accent, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Ayat Kunci & Renungan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF735C0E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        surah.keyVerse!,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Poin-poin Tadabbur Ringkas
            const Text(
              'Poin Tadabbur & Aplikatif',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            if (surah.tadabburPoints.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Poin tadabbur akan segera ditambahkan.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              ...List.generate(surah.tadabburPoints.length, (idx) {
                final point = surah.tadabburPoints[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.5,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
