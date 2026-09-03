import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/utils/ntp_time_helper.dart';
import '../data/datasources/local_persistent_cache.dart';
import '../data/models/exam_session.dart';
import '../data/models/question.dart';
import '../data/models/wrong_question.dart';
import '../data/repositories/repository_factory.dart';

class MockExamController extends ChangeNotifier {
  final RepositoryFactory repositoryFactory;
  final LocalPersistentCache localCache;

  List<Question> _examQuestions = [];
  int _currentIndex = 0;
  final Map<int, Set<int>> _userAnswers = {}; // 題目 index ➔ 使用者選擇的選項
  DateTime? _startTime;
  bool _isExamCompleted = false;
  ExamSession? _lastCompletedSession;

  // 計時器局部重繪 ValueNotifier (秒數)，杜絕全頁面重建！
  final ValueNotifier<int> remainingSecondsNotifier = ValueNotifier<int>(0);
  Timer? _timer;

  MockExamController({
    required this.repositoryFactory,
    required this.localCache,
  });

  List<Question> get examQuestions => _examQuestions;
  int get currentIndex => _currentIndex;
  Map<int, Set<int>> get userAnswers => _userAnswers;
  bool get isExamCompleted => _isExamCompleted;
  ExamSession? get lastCompletedSession => _lastCompletedSession;

  Question? get currentQuestion =>
      _examQuestions.isNotEmpty && _currentIndex < _examQuestions.length
          ? _examQuestions[_currentIndex]
          : null;

  Set<int> get currentSelectedOptions => _userAnswers[_currentIndex] ?? {};

  void startMockExam({
    required String subjectId,
    required int questionCount,
    int durationMinutes = 60,
  }) async {
    final repo = repositoryFactory.getQuestionRepository(subjectId);
    final allQuestions = await repo.getQuestions();

    // 隨機抽取指定題數
    final shuffled = List<Question>.from(allQuestions)..shuffle();
    _examQuestions = shuffled.take(questionCount).toList();

    _currentIndex = 0;
    _userAnswers.clear();
    _isExamCompleted = false;
    _lastCompletedSession = null;
    _startTime = DateTime.now();

    // 啟動計時器
    _timer?.cancel();
    remainingSecondsNotifier.value = durationMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSecondsNotifier.value > 0) {
        remainingSecondsNotifier.value--;
      } else {
        _timer?.cancel();
        submitExam(subjectId: subjectId, userId: 'usr_current');
      }
    });

    notifyListeners();
  }

  void toggleOption(int optionIndex) {
    if (_isExamCompleted) return;
    final q = currentQuestion;
    if (q == null) return;

    final currentSet = Set<int>.from(_userAnswers[_currentIndex] ?? {});
    if (q.type == 'SINGLE_CHOICE' || q.type == 'SIMULATION') {
      currentSet.clear();
      currentSet.add(optionIndex);
    } else {
      if (currentSet.contains(optionIndex)) {
        currentSet.remove(optionIndex);
      } else {
        currentSet.add(optionIndex);
      }
    }
    _userAnswers[_currentIndex] = currentSet;
    notifyListeners();
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < _examQuestions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentIndex < _examQuestions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void prevQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  Future<ExamSession> submitExam({
    required String subjectId,
    required String userId,
  }) async {
    _timer?.cancel();
    _isExamCompleted = true;
    final endTime = DateTime.now();

    // NTP 防作弊網路時間驗證
    final isTampered = await NtpTimeHelper.isSystemTimeTampered();
    final isNtpVerified = !isTampered;

    int correctCount = 0;
    final Map<String, int> domainTotal = {};
    final Map<String, int> domainCorrect = {};
    final List<ExamAnswer> answers = [];
    final List<Question> wrongQuestionsToRecord = [];

    for (int i = 0; i < _examQuestions.length; i++) {
      final q = _examQuestions[i];
      final selected = (_userAnswers[i] ?? {}).toList()..sort();
      final correct = List<int>.from(q.correctAnswer)..sort();
      final isCorrect = listEquals(selected, correct);

      if (isCorrect) {
        correctCount++;
      } else {
        wrongQuestionsToRecord.add(q);
      }

      // 領域統計
      domainTotal[q.topic] = (domainTotal[q.topic] ?? 0) + 1;
      if (isCorrect) {
        domainCorrect[q.topic] = (domainCorrect[q.topic] ?? 0) + 1;
      }

      answers.add(
        ExamAnswer(
          questionId: q.id,
          userSelectedOptions: selected,
          isCorrect: isCorrect,
          timeSpentSeconds: 0,
        ),
      );
    }

    // 自動收集錯題至錯題本集合中
    if (wrongQuestionsToRecord.isNotEmpty) {
      final existingWrongList = localCache.getWrongQuestions();
      for (final q in wrongQuestionsToRecord) {
        final existingIdx = existingWrongList.indexWhere((w) => w.questionId == q.id);
        if (existingIdx >= 0) {
          final current = existingWrongList[existingIdx];
          existingWrongList[existingIdx] = current.copyWith(
            wrongCount: current.wrongCount + 1,
            lastWrongTime: DateTime.now(),
            isMastered: false,
            cachedQuestion: q,
          );
        } else {
          existingWrongList.insert(
            0,
            WrongQuestion(
              questionId: q.id,
              examId: q.examId,
              topic: q.topic,
              wrongCount: 1,
              lastWrongTime: DateTime.now(),
              isMastered: false,
              cachedQuestion: q,
            ),
          );
        }
      }
      await localCache.saveWrongQuestions(existingWrongList);
    }

    final scorePercentage = _examQuestions.isNotEmpty
        ? (correctCount / _examQuestions.length) * 100
        : 0.0;
    final isPassed = scorePercentage >= 80.0; // Cisco 標準 80% 通過

    final Map<String, double> domainBreakdown = {};
    domainTotal.forEach((domain, total) {
      final cor = domainCorrect[domain] ?? 0;
      domainBreakdown[domain] = (cor / total) * 100;
    });

    final session = ExamSession(
      id: 'session_${const Uuid().v4().substring(0, 8)}',
      userId: userId,
      examId: subjectId,
      startTime: _startTime ?? DateTime.now(),
      endTime: endTime,
      totalQuestions: _examQuestions.length,
      correctCount: correctCount,
      scorePercentage: double.parse(scorePercentage.toStringAsFixed(1)),
      isPassed: isPassed,
      domainBreakdown: domainBreakdown,
      answers: answers,
      isNtpVerified: isNtpVerified,
    );

    _lastCompletedSession = session;

    // 儲存至本地快取
    final sessions = localCache.getExamSessions();
    sessions.insert(0, session);
    await localCache.saveExamSessions(sessions);

    notifyListeners();
    return session;
  }

  @override
  void dispose() {
    _timer?.cancel();
    remainingSecondsNotifier.dispose();
    super.dispose();
  }
}
