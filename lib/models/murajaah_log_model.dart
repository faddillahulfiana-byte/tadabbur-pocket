import 'surah_model.dart';

class MurajaahLog {
  final String id;
  final String userId;
  final int surahId;
  final String verseRange;
  final bool isFullSurah;
  final String fluencyLevel; // 'lancar' | 'perlu_diulang' | 'belum_lancar'
  final String? notes;
  final DateTime murajaahAt;
  final DateTime? createdAt;
  final Surah? surah;

  MurajaahLog({
    required this.id,
    required this.userId,
    required this.surahId,
    required this.verseRange,
    required this.isFullSurah,
    required this.fluencyLevel,
    this.notes,
    required this.murajaahAt,
    this.createdAt,
    this.surah,
  });

  String get fluencyLabel {
    switch (fluencyLevel) {
      case 'lancar':
        return 'Lancar / Mutqin';
      case 'perlu_diulang':
        return 'Perlu Diulang';
      case 'belum_lancar':
        return 'Belum Lancar';
      default:
        return fluencyLevel;
    }
  }

  factory MurajaahLog.fromMap(Map<String, dynamic> map) {
    Surah? joinedSurah;
    if (map['surahs'] != null && map['surahs'] is Map<String, dynamic>) {
      joinedSurah = Surah.fromMap(map['surahs'] as Map<String, dynamic>);
    }

    return MurajaahLog(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      surahId: map['surah_id'] is int
          ? map['surah_id']
          : int.tryParse(map['surah_id'].toString()) ?? 0,
      verseRange: map['verse_range'] ?? '1 - Selesai',
      isFullSurah: map['is_full_surah'] ?? true,
      fluencyLevel: map['fluency_level'] ?? 'lancar',
      notes: map['notes'],
      murajaahAt: map['murajaah_at'] != null
          ? DateTime.tryParse(map['murajaah_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      surah: joinedSurah,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'surah_id': surahId,
      'verse_range': verseRange,
      'is_full_surah': isFullSurah,
      'fluency_level': fluencyLevel,
      'notes': notes,
      'murajaah_at': murajaahAt.toIso8601String(),
    };
  }
}
