import 'question.dart';

class WrongQuestion {
  final String questionId;
  final String examId;
  final String topic;
  final int wrongCount;
  final DateTime lastWrongTime;
  final bool isMastered;
  final Question? cachedQuestion;

  WrongQuestion({
    required this.questionId,
    required this.examId,
    required this.topic,
    required this.wrongCount,
    required this.lastWrongTime,
    this.isMastered = false,
    this.cachedQuestion,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'examId': examId,
      'topic': topic,
      'wrongCount': wrongCount,
      'lastWrongTime': lastWrongTime.toIso8601String(),
      'isMastered': isMastered,
      'cachedQuestion': cachedQuestion?.toMap(),
    };
  }

  factory WrongQuestion.fromMap(Map<String, dynamic> map) {
    return WrongQuestion(
      questionId: map['questionId'] ?? '',
      examId: map['examId'] ?? '',
      topic: map['topic'] ?? '',
      wrongCount: map['wrongCount'] ?? 1,
      lastWrongTime: DateTime.tryParse(map['lastWrongTime']?.toString() ?? '') ?? DateTime.now(),
      isMastered: map['isMastered'] ?? false,
      cachedQuestion: map['cachedQuestion'] != null
          ? Question.fromMap(Map<String, dynamic>.from(map['cachedQuestion']))
          : null,
    );
  }

  WrongQuestion copyWith({
    String? questionId,
    String? examId,
    String? topic,
    int? wrongCount,
    DateTime? lastWrongTime,
    bool? isMastered,
    Question? cachedQuestion,
  }) {
    return WrongQuestion(
      questionId: questionId ?? this.questionId,
      examId: examId ?? this.examId,
      topic: topic ?? this.topic,
      wrongCount: wrongCount ?? this.wrongCount,
      lastWrongTime: lastWrongTime ?? this.lastWrongTime,
      isMastered: isMastered ?? this.isMastered,
      cachedQuestion: cachedQuestion ?? this.cachedQuestion,
    );
  }
}
