import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/app_helpers.dart';
import '../../providers/murajaah_provider.dart';
import '../../providers/surah_provider.dart';

class AddMurajaahDialog extends StatefulWidget {
  final int? initialSurahId;

  const AddMurajaahDialog({super.key, this.initialSurahId});

  @override
  State<AddMurajaahDialog> createState() => _AddMurajaahDialogState();
}

class _AddMurajaahDialogState extends State<AddMurajaahDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedSurahId;
  bool _isFullSurah = true;
  final _verseRangeController = TextEditingController();
  final _notesController = TextEditingController();
  String _fluencyLevel = 'lancar';
  DateTime _murajaahAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedSurahId = widget.initialSurahId;
    final surahs = context.read<SurahProvider>().surahs;
    if (_selectedSurahId == null && surahs.isNotEmpty) {
      _selectedSurahId = surahs.first.id;
    }
  }

  @override
  void dispose() {
    _verseRangeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSurahId == null) {
      AppHelpers.showSnackBar(context, 'Pilih surah yang di-murajaah', isError: true);
      return;
    }

    final murajaahProvider = context.read<MurajaahProvider>();
    final success = await murajaahProvider.addLog(
      surahId: _selectedSurahId!,
      verseRange: _isFullSurah ? '1 - Selesai' : _verseRangeController.text.trim(),
      isFullSurah: _isFullSurah,
      fluencyLevel: _fluencyLevel,
      notes: _notesController.text,
      murajaahAt: _murajaahAt,
    );

    if (mounted) {
      if (success) {
        AppHelpers.showSnackBar(context, 'Catatan murajaah berhasil disimpan!');
        Navigator.pop(context);
      } else {
        AppHelpers.showSnackBar(
          context,
          murajaahProvider.errorMessage ?? 'Gagal menyimpan catatan.',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final surahProvider = context.watch<SurahProvider>();
    final murajaahProvider = context.watch<MurajaahProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Catat Sesi Murajaah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Pilih Surah
                const Text(
                  'Surah yang Di-murajaah',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedSurahId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.menu_book_rounded),
                  ),
                  items: surahProvider.surahs.map((s) {
                    return DropdownMenuItem<int>(
                      value: s.id,
                      child: Text(
                        '${s.surahNumber}. ${s.latinName} (${s.meaning})',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSurahId = val;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Centang Satu Surah Penuh
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Satu Surah Penuh',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  value: _isFullSurah,
                  activeColor: AppTheme.primary,
                  onChanged: (val) {
                    setState(() {
                      _isFullSurah = val ?? true;
                    });
                  },
                ),

                if (!_isFullSurah) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _verseRangeController,
                    decoration: const InputDecoration(
                      labelText: 'Rentang Ayat',
                      hintText: 'Misal: Ayat 1 - 15',
                      prefixIcon: Icon(Icons.format_list_numbered_rounded),
                    ),
                    validator: (val) {
                      if (!_isFullSurah && (val == null || val.trim().isEmpty)) {
                        return 'Tuliskan rentang ayat yang diulang';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // Status Kelancaran
                const Text(
                  'Status Kelancaran',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFluencyChip('lancar', 'Lancar', Icons.check_circle_rounded, AppTheme.success),
                    const SizedBox(width: 8),
                    _buildFluencyChip('perlu_diulang', 'Perlu Diulang', Icons.replay_rounded, AppTheme.warning),
                    const SizedBox(width: 8),
                    _buildFluencyChip('belum_lancar', 'Belum Lancar', Icons.cancel_rounded, AppTheme.danger),
                  ],
                ),
                const SizedBox(height: 16),

                // Catatan Tambahan (Opsional)
                const Text(
                  'Catatan Pribadi (Opsional)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Misal: Sedikit ragu di ayat 12-14',
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                ElevatedButton(
                  onPressed: murajaahProvider.isLoading ? null : _handleSave,
                  child: murajaahProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan Catatan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFluencyChip(String value, String label, IconData icon, Color color) {
    final isSelected = _fluencyLevel == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _fluencyLevel = value;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : AppTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? color : AppTheme.textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
