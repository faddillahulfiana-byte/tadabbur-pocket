class Surah {
  final int id;
  final int surahNumber;
  final String arabicName;
  final String latinName;
  final String meaning;
  final int totalVerses;
  final String revelationType;
  final String mainTheme;
  final List<String> tadabburPoints;
  final String? keyVerse;

  Surah({
    required this.id,
    required this.surahNumber,
    required this.arabicName,
    required this.latinName,
    required this.meaning,
    required this.totalVerses,
    required this.revelationType,
    required this.mainTheme,
    required this.tadabburPoints,
    this.keyVerse,
  });

  factory Surah.fromMap(Map<String, dynamic> map) {
    List<String> points = [];
    if (map['tadabbur_points'] != null) {
      if (map['tadabbur_points'] is List) {
        points = (map['tadabbur_points'] as List)
            .map((e) => e.toString())
            .toList();
      }
    }

    return Surah(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      surahNumber: map['surah_number'] ?? 0,
      arabicName: map['arabic_name'] ?? '',
      latinName: map['latin_name'] ?? '',
      meaning: map['meaning'] ?? '',
      totalVerses: map['total_verses'] ?? 0,
      revelationType: map['revelation_type'] ?? 'Makkiyah',
      mainTheme: map['main_theme'] ?? '',
      tadabburPoints: points,
      keyVerse: map['key_verse'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'surah_number': surahNumber,
      'arabic_name': arabicName,
      'latin_name': latinName,
      'meaning': meaning,
      'total_verses': totalVerses,
      'revelation_type': revelationType,
      'main_theme': mainTheme,
      'tadabbur_points': tadabburPoints,
      'key_verse': keyVerse,
    };
  }
}
