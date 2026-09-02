class ExamAnswer {
  final String questionId;
  final List<int> userSelectedOptions;
  final bool isCorrect;
  final int timeSpentSeconds;

  ExamAnswer({
    required this.questionId,
    required this.userSelectedOptions,
    required this.isCorrect,
    required this.timeSpentSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'userSelectedOptions': userSelectedOptions,
      'isCorrect': isCorrect,
      'timeSpentSeconds': timeSpentSeconds,
    };
  }

  factory ExamAnswer.fromMap(Map<String, dynamic> map) {
    return ExamAnswer(
      questionId: map['questionId'] ?? '',
      userSelectedOptions: List<int>.from(map['userSelectedOptions'] ?? []),
      isCorrect: map['isCorrect'] ?? false,
      timeSpentSeconds: map['timeSpentSeconds'] ?? 0,
    );
  }
}

class ExamSession {
  final String id;
  final String userId;
  final String examId;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalQuestions;
  final int correctCount;
  final double scorePercentage;
  final bool isPassed;
  final Map<String, double> domainBreakdown; // 領域得分率
  final List<ExamAnswer> answers;

  ExamSession({
    required this.id,
    required this.userId,
    required this.examId,
    required this.startTime,
    this.endTime,
    required this.totalQuestions,
    required this.correctCount,
    required this.scorePercentage,
    required this.isPassed,
    required this.domainBreakdown,
    required this.answers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'examId': examId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'scorePercentage': scorePercentage,
      'isPassed': isPassed,
      'domainBreakdown': domainBreakdown,
      'answers': answers.map((a) => a.toMap()).toList(),
    };
  }

  factory ExamSession.fromMap(Map<String, dynamic> map) {
    return ExamSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      examId: map['examId'] ?? '',
      startTime: DateTime.tryParse(map['startTime']?.toString() ?? '') ?? DateTime.now(),
      endTime: map['endTime'] != null ? DateTime.tryParse(map['endTime'].toString()) : null,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctCount: map['correctCount'] ?? 0,
      scorePercentage: (map['scorePercentage'] as num?)?.toDouble() ?? 0.0,
      isPassed: map['isPassed'] ?? false,
      domainBreakdown: (map['domainBreakdown'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      answers: (map['answers'] as List<dynamic>?)
              ?.map((a) => ExamAnswer.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
