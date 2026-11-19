import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../models/quote_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quote_provider.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quoteProvider = context.watch<QuoteProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote & Mutiara Islami'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          tabs: [
            const Tab(
              icon: Icon(Icons.explore_outlined, size: 20),
              text: 'Jelajah Quote',
            ),
            Tab(
              icon: const Icon(Icons.favorite_rounded, size: 20),
              text: 'Favorit (${quoteProvider.favoriteQuotes.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Jelajah Semua Quote
          _buildExploreTab(context, quoteProvider, authProvider),

          // Tab 2: Koleksi Favorit
          _buildFavoritesTab(context, quoteProvider, authProvider),
        ],
      ),
    );
  }

  Widget _buildExploreTab(
    BuildContext context,
    QuoteProvider quoteProvider,
    AuthProvider authProvider,
  ) {
    return RefreshIndicator(
      onRefresh: () => quoteProvider.fetchQuotes(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter Kategori Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(quoteProvider, 'all', 'Semua (${quoteProvider.allQuotes.length})'),
                  const SizedBox(width: 8),
                  _buildFilterChip(quoteProvider, 'quran_verse', 'Ayat Al-Qur''an'),
                  const SizedBox(width: 8),
                  _buildFilterChip(quoteProvider, 'motivation', 'Motivasi Islami'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (quoteProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (quoteProvider.filteredQuotes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('Tidak ada quote untuk kategori ini.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quoteProvider.filteredQuotes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, index) {
                  final quote = quoteProvider.filteredQuotes[index];
                  return _buildQuoteItemCard(context, quote, quoteProvider, authProvider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(QuoteProvider provider, String category, String label) {
    final isSelected = provider.selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryLight.withOpacity(0.15),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primary : const Color(0xFFD2E0D8),
      ),
      onSelected: (_) => provider.setCategory(category),
    );
  }

  Widget _buildFavoritesTab(
    BuildContext context,
    QuoteProvider quoteProvider,
    AuthProvider authProvider,
  ) {
    if (authProvider.isGuest) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border_rounded, size: 54, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              const Text(
                'Simpan Quote Favorit Anda',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk akun untuk menyimpan kata mutiara dan ayat Al-Qur''an favorit ke dalam daftar tersimpan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  AppHelpers.requireLogin(
                    context,
                    actionMessage: 'melihat dan mengelola quote favorit Anda',
                  );
                },
                child: const Text('Masuk / Daftar Akun'),
              ),
            ],
          ),
        ),
      );
    }

    final favorites = quoteProvider.favoriteQuotes;

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark_outline_rounded, size: 48, color: AppTheme.textMuted),
              const SizedBox(height: 12),
              const Text(
                'Belum Ada Quote Favorit',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tekan ikon hati pada quote yang menginspirasi Anda untuk menyimpannya di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, index) {
        final quote = favorites[index];
        return _buildQuoteItemCard(context, quote, quoteProvider, authProvider);
      },
    );
  }

  Widget _buildQuoteItemCard(
    BuildContext context,
    Quote quote,
    QuoteProvider quoteProvider,
    AuthProvider authProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: quote.isQuranVerse
                        ? AppTheme.primaryLight.withOpacity(0.12)
                        : AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    quote.isQuranVerse ? 'Ayat Al-Qur''an' : 'Mutiara Hikmah',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: quote.isQuranVerse ? AppTheme.primary : const Color(0xFF8C6D0B),
                    ),
                  ),
                ),
                Text(
                  quote.topic,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (quote.arabicText != null && quote.arabicText!.isNotEmpty) ...[
              Text(
                quote.arabicText!,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.8,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
            ],

            Text(
              '"${quote.content}"',
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontStyle: FontStyle.italic,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '— ${quote.sourceRef}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Bagikan Quote',
                      icon: const Icon(Icons.share_outlined, size: 18, color: AppTheme.textSecondary),
                      onPressed: () {
                        final text =
                            '${quote.arabicText != null ? "${quote.arabicText}\n\n" : ""}"${quote.content}"\n\n— ${quote.sourceRef}\n(Dibagikan dari Tadabbur Pocket)';
                        Share.share(text);
                      },
                    ),
                    IconButton(
                      tooltip: quote.isFavorite ? 'Hapus Favorit' : 'Simpan Favorit',
                      icon: Icon(
                        quote.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: quote.isFavorite ? Colors.red : AppTheme.textMuted,
                        size: 20,
                      ),
                      onPressed: () async {
                        if (authProvider.isGuest) {
                          await AppHelpers.requireLogin(
                            context,
                            actionMessage: 'menyimpan quote ini ke favorit Anda',
                          );
                          return;
                        }

                        final ok = await quoteProvider.toggleFavorite(quote);
                        if (context.mounted && ok) {
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
        ),
      ),
    );
  }
}
