class RagKnowledgeChunk {
  final String id;
  final String bookTitle;
  final String chapter;
  final int pageNumber;
  final String topic;
  final String content;
  final double qualityScore; // 0.0 ~ 1.0 五大維度品質評分
  final List<String> keywords;

  RagKnowledgeChunk({
    required this.id,
    required this.bookTitle,
    required this.chapter,
    required this.pageNumber,
    required this.topic,
    required this.content,
    this.qualityScore = 0.95,
    this.keywords = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookTitle': bookTitle,
      'chapter': chapter,
      'pageNumber': pageNumber,
      'topic': topic,
      'content': content,
      'qualityScore': qualityScore,
      'keywords': keywords,
    };
  }

  factory RagKnowledgeChunk.fromMap(Map<String, dynamic> map) {
    return RagKnowledgeChunk(
      id: map['id'] ?? '',
      bookTitle: map['bookTitle'] ?? 'Official Cert Guide',
      chapter: map['chapter'] ?? '',
      pageNumber: (map['pageNumber'] as num?)?.toInt() ?? 1,
      topic: map['topic'] ?? '',
      content: map['content'] ?? '',
      qualityScore: (map['qualityScore'] as num?)?.toDouble() ?? 0.95,
      keywords: List<String>.from(map['keywords'] ?? []),
    );
  }
}
