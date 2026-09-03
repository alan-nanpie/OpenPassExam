import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../data/models/exam_subject.dart';
import '../data/models/question.dart';
import '../data/models/wrong_question.dart';
import '../data/datasources/local_persistent_cache.dart';
import '../data/repositories/repository_factory.dart';
import '../data/repositories/subject_repository.dart';
import '../core/constants/exam_subjects_data.dart';

class ExamController extends ChangeNotifier {
  final RepositoryFactory repositoryFactory;
  final LocalPersistentCache localCache;
  final ISubjectRepository? subjectRepository;

  String _currentSubjectId = AppConstants.defaultSubjectId;
  List<Question> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = false;

  // 考試科目集合
  List<ExamSubject> _allSubjects = [];

  // 使用者目前的作答狀態
  final Set<int> _selectedOptionIndices = {};
  bool _isAnswerSubmitted = false;
  bool _isCurrentCorrect = false;

  // 語系解析切換: 'zh_TW', 'en', 'ja', 'zh_CN'
  String _activeExplanationLanguage = 'zh_TW';

  ExamController({
    required this.repositoryFactory,
    required this.localCache,
    this.subjectRepository,
  }) {
    loadAllSubjects();
  }

  List<ExamSubject> get allSubjects =>
      _allSubjects.isNotEmpty ? _allSubjects : ExamSubjectsData.allSubjects;
  List<ExamSubject> get officialSubjects => allSubjects.where((s) => s.isOfficial).toList();
  List<ExamSubject> get customSubjects => allSubjects.where((s) => !s.isOfficial).toList();

  Future<void> loadAllSubjects() async {
    if (subjectRepository != null) {
      _allSubjects = await subjectRepository!.getAllSubjects();
    } else {
      _allSubjects = List.from(ExamSubjectsData.allSubjects);
    }
    notifyListeners();
  }

  Future<void> addCustomSubject(
    ExamSubject subject, {
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    if (subjectRepository != null) {
      await subjectRepository!.saveSubject(subject, currentUserId: currentUserId, isAdmin: isAdmin);
    }
    await loadAllSubjects();
  }

  Future<void> deleteCustomSubject(
    String subjectId, {
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    if (subjectRepository != null) {
      await subjectRepository!.deleteSubject(subjectId, currentUserId: currentUserId, isAdmin: isAdmin);
    }
    await loadAllSubjects();
  }

  String get currentSubjectId => _currentSubjectId;
  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  Set<int> get selectedOptionIndices => _selectedOptionIndices;
  bool get isAnswerSubmitted => _isAnswerSubmitted;
  bool get isCurrentCorrect => _isCurrentCorrect;
  String get activeExplanationLanguage => _activeExplanationLanguage;

  Question? get currentQuestion =>
      _questions.isNotEmpty && _currentIndex < _questions.length
          ? _questions[_currentIndex]
          : null;

  Future<void> loadQuestionsForSubject(String subjectId) async {
    _currentSubjectId = subjectId;
    _isLoading = true;
    _currentIndex = 0;
    _clearAnswerState();
    notifyListeners();

    final repo = repositoryFactory.getQuestionRepository(subjectId);
    _questions = await repo.getQuestions();
    _isLoading = false;
    notifyListeners();
  }

  void selectSubject(ExamSubject subject) {
    loadQuestionsForSubject(subject.id);
  }

  void toggleOption(int index) {
    if (_isAnswerSubmitted) return;
    final q = currentQuestion;
    if (q == null) return;

    if (q.type == 'SINGLE_CHOICE' || q.type == 'SIMULATION') {
      _selectedOptionIndices.clear();
      _selectedOptionIndices.add(index);
    } else {
      // 複選或拖曳
      if (_selectedOptionIndices.contains(index)) {
        _selectedOptionIndices.remove(index);
      } else {
        _selectedOptionIndices.add(index);
      }
    }
    notifyListeners();
  }

  void submitAnswer() {
    final q = currentQuestion;
    if (q == null || _selectedOptionIndices.isEmpty || _isAnswerSubmitted) return;

    _isAnswerSubmitted = true;
    final selectedList = _selectedOptionIndices.toList()..sort();
    final correctList = List<int>.from(q.correctAnswer)..sort();

    _isCurrentCorrect = listEquals(selectedList, correctList);

    // 若答錯，自動記錄至錯題本
    if (!_isCurrentCorrect) {
      _recordWrongQuestion(q);
    }

    notifyListeners();
  }

  Future<void> _recordWrongQuestion(Question question) async {
    final list = localCache.getWrongQuestions();
    final idx = list.indexWhere((w) => w.questionId == question.id);
    if (idx >= 0) {
      final existing = list[idx];
      list[idx] = existing.copyWith(
        wrongCount: existing.wrongCount + 1,
        lastWrongTime: DateTime.now(),
        isMastered: false,
        cachedQuestion: question,
      );
    } else {
      list.add(
        WrongQuestion(
          questionId: question.id,
          examId: question.examId,
          topic: question.topic,
          wrongCount: 1,
          lastWrongTime: DateTime.now(),
          isMastered: false,
          cachedQuestion: question,
        ),
      );
    }
    await localCache.saveWrongQuestions(list);
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _clearAnswerState();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _clearAnswerState();
      notifyListeners();
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      _clearAnswerState();
      notifyListeners();
    }
  }

  void setExplanationLanguage(String lang) {
    _activeExplanationLanguage = lang;
    notifyListeners();
  }

  String getLocalizedExplanation(Question question) {
    switch (_activeExplanationLanguage) {
      case 'ja':
        return question.explanationJa ?? question.explanation;
      case 'zh_TW':
        return question.explanationZhTw ?? question.explanation;
      case 'zh_CN':
        return question.explanationZhTw ?? question.explanation;
      case 'en':
      default:
        return question.explanation;
    }
  }

  void _clearAnswerState() {
    _selectedOptionIndices.clear();
    _isAnswerSubmitted = false;
    _isCurrentCorrect = false;
  }
}
