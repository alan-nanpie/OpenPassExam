class QuestionComment {
  final String id;
  final String questionId;
  final String examId;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestionComment({
    required this.id,
    required this.questionId,
    required this.examId,
    required this.authorId,
    required this.authorName,
    this.authorRole = 'viewer',
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 檢查當前使用者是否為該留言的原作者本人
  bool isAuthor(String? currentUid) {
    if (currentUid == null || currentUid.isEmpty) return false;
    return authorId == currentUid;
  }

  /// 檢查是否有編輯或刪除此留言的權限 (原作者本人或系統管理員)
  bool canEdit({String? currentUid, bool isAdmin = false}) {
    if (isAdmin) return true;
    return isAuthor(currentUid);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'examId': examId,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory QuestionComment.fromMap(Map<String, dynamic> map) {
    return QuestionComment(
      id: (map['id'] ?? '').toString(),
      questionId: (map['questionId'] ?? map['question_id'] ?? '').toString(),
      examId: (map['examId'] ?? map['exam_id'] ?? '').toString(),
      authorId: (map['authorId'] ?? map['author_id'] ?? '').toString(),
      authorName: (map['authorName'] ?? map['author_name'] ?? '學員').toString(),
      authorRole: (map['authorRole'] ?? map['author_role'] ?? 'viewer').toString(),
      content: (map['content'] ?? '').toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  QuestionComment copyWith({
    String? id,
    String? questionId,
    String? examId,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuestionComment(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      examId: examId ?? this.examId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
