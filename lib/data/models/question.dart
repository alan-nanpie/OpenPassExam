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
  final String creatorId; // 建立者 UID (例如 'system' 或使用者 uid)
  final String? creatorName; // 建立者顯示名稱
  final bool isPublic; // 是否公開供其他使用者讀取
  final DateTime? updatedAt;

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
    this.creatorId = 'system',
    this.creatorName = 'PassExam 官方教研組',
    this.isPublic = true,
    this.updatedAt,
  });

  /// 檢查當前使用者是否為該考題的建立者本人
  bool isOwner(String? currentUid) {
    if (currentUid == null || currentUid.isEmpty) return false;
    return creatorId == currentUid;
  }

  /// 判斷是否有編輯或刪除此考題的權限 (建立者本人或管理員)
  bool canEdit({String? currentUid, bool isAdmin = false}) {
    if (isAdmin) return true;
    return isOwner(currentUid);
  }

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
      creatorId: (map['creatorId'] ?? map['creator_id'] ?? 'system').toString(),
      creatorName: (map['creatorName'] ?? map['creator_name'] ?? 'PassExam 官方教研組').toString(),
      isPublic: map['isPublic'] ?? map['is_public'] ?? true,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
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
      'creatorId': creatorId,
      'creatorName': creatorName,
      'isPublic': isPublic,
      'updatedAt': updatedAt?.toIso8601String(),
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
    String? creatorId,
    String? creatorName,
    bool? isPublic,
    DateTime? updatedAt,
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
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      isPublic: isPublic ?? this.isPublic,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
