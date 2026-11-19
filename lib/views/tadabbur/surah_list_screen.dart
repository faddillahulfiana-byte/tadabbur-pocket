import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../models/surah_model.dart';
import '../../providers/surah_provider.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatelessWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surahProvider = context.watch<SurahProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tadabbur Juz 30'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (val) => surahProvider.searchSurahs(val),
              decoration: InputDecoration(
                hintText: 'Cari nama surah, arti, atau nomor...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
                suffixIcon: surahProvider.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () => surahProvider.searchSurahs(''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: AppTheme.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => surahProvider.fetchSurahs(),
        child: surahProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : surahProvider.errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            surahProvider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => surahProvider.fetchSurahs(),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : surahProvider.surahs.isEmpty
                    ? const Center(
                        child: Text(
                          'Surah tidak ditemukan.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: surahProvider.surahs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final surah = surahProvider.surahs[index];
                          return _buildSurahCard(context, surah);
                        },
                      ),
      ),
    );
  }

  Widget _buildSurahCard(BuildContext context, Surah surah) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(surah: surah),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Nomor Surah Badge
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${surah.surahNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Detail Latin & Arti
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.latinName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${surah.meaning} • ${surah.totalVerses} Ayat (${surah.revelationType})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Teks Arab Surah
              Text(
                surah.arabicName,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
