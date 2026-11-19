class Quote {
  final String id;
  final String quoteType; // 'quran_verse' | 'motivation'
  final String content;
  final String? arabicText;
  final String sourceRef;
  final String topic;
  final DateTime? createdAt;
  bool isFavorite;

  Quote({
    required this.id,
    required this.quoteType,
    required this.content,
    this.arabicText,
    required this.sourceRef,
    required this.topic,
    this.createdAt,
    this.isFavorite = false,
  });

  bool get isQuranVerse => quoteType == 'quran_verse';

  factory Quote.fromMap(Map<String, dynamic> map, {bool isFav = false}) {
    return Quote(
      id: map['id']?.toString() ?? '',
      quoteType: map['quote_type'] ?? 'motivation',
      content: map['content'] ?? '',
      arabicText: map['arabic_text'],
      sourceRef: map['source_ref'] ?? '',
      topic: map['topic'] ?? 'Umum',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      isFavorite: isFav,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quote_type': quoteType,
      'content': content,
      'arabic_text': arabicText,
      'source_ref': sourceRef,
      'topic': topic,
    };
  }
}
