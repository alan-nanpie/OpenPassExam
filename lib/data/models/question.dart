class Question {
  final String id;
  final String examId;
  final String type; // SINGLE_CHOICE, MULTIPLE_CHOICE, DRAG_DROP, SIMULATION
  final String title;
  final List<String> options;
  final List<int> correctAnswer;
  final String explanation;
  final String? explanationJa;
  final String? explanationZhTw;
  final String topic;
  final String? imageUrl;
  final bool isApproved;
  final String? englishGrammarNotes; // 從考題學英文分析

  Question({
    required this.id,
    required this.examId,
    required this.type,
    required this.title,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.explanationJa,
    this.explanationZhTw,
    required this.topic,
    this.imageUrl,
    required this.isApproved,
    this.englishGrammarNotes,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: (map['id'] ?? map['question_id'] ?? '').toString(),
      examId: (map['examId'] ?? map['exam_id'] ?? '').toString(),
      type: (map['type'] ?? 'SINGLE_CHOICE').toString().toUpperCase(),
      title: (map['title'] ?? map['question_text'] ?? '').toString(),
      options: (map['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[],
      correctAnswer: ((map['correctAnswer'] ?? map['correct_answer']) as List<dynamic>?)
              ?.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
              .toList() ??
          <int>[],
      explanation: (map['explanation'] ?? '').toString(),
      explanationJa: (map['explanationJa'] ?? map['explanation_ja'])?.toString(),
      explanationZhTw:
          (map['explanationZhTw'] ?? map['explanation_zh_tw'])?.toString(),
      topic: (map['topic'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? map['image_url'])?.toString(),
      isApproved: map['isApproved'] ?? map['is_approved'] ?? true,
      englishGrammarNotes: (map['englishGrammarNotes'] ?? map['english_grammar_notes'])?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examId': examId,
      'type': type,
      'title': title,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'explanationJa': explanationJa,
      'explanationZhTw': explanationZhTw,
      'topic': topic,
      'imageUrl': imageUrl,
      'isApproved': isApproved,
      'englishGrammarNotes': englishGrammarNotes,
    };
  }

  Question copyWith({
    String? id,
    String? examId,
    String? type,
    String? title,
    List<String>? options,
    List<int>? correctAnswer,
    String? explanation,
    String? explanationJa,
    String? explanationZhTw,
    String? topic,
    String? imageUrl,
    bool? isApproved,
    String? englishGrammarNotes,
  }) {
    return Question(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      type: type ?? this.type,
      title: title ?? this.title,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      explanationJa: explanationJa ?? this.explanationJa,
      explanationZhTw: explanationZhTw ?? this.explanationZhTw,
      topic: topic ?? this.topic,
      imageUrl: imageUrl ?? this.imageUrl,
      isApproved: isApproved ?? this.isApproved,
      englishGrammarNotes: englishGrammarNotes ?? this.englishGrammarNotes,
    );
  }
}
