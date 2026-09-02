import '../datasources/local_persistent_cache.dart';
import '../datasources/mock_seed_data.dart';
import '../datasources/rtdb_approved_keys_datasource.dart';
import '../models/question.dart';

abstract class IQuestionRepository {
  Future<List<Question>> getQuestions({bool forceRefresh = false});
  Future<Question?> getQuestionById(String id);
  Future<List<Question>> getQuestionsByDomain(String domain);
  Future<void> saveQuestion(Question question);
  Future<void> deleteQuestion(String id);
  Future<void> approveAllQuestions();
  Future<void> setQuestionApproval(String id, bool isApproved);
}

class FirestoreQuestionRepository implements IQuestionRepository {
  final String subjectId;
  final LocalPersistentCache localCache;
  final RtdbApprovedKeysDatasource rtdbDatasource;

  FirestoreQuestionRepository({
    required this.subjectId,
    required this.localCache,
    required this.rtdbDatasource,
  });

  @override
  Future<List<Question>> getQuestions({bool forceRefresh = false}) async {
    // 1. 優先從本地持久化快取 (Local Persistent Cache) 瞬間讀取
    if (!forceRefresh) {
      final cached = localCache.getCachedQuestions(subjectId);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    // 2. 模擬從 Cloud Firestore 集合 (exam_subjects/{subjectId}/questions) 載入並結合 RTDB approvedKeys
    final allSeed = MockSeedData.getInitialQuestions();
    final subjectQuestions = allSeed.where((q) => q.examId == subjectId).toList();

    // 如果該考科暫無特化題目，提供範本樣題確保 18+ 科目均可練習
    if (subjectQuestions.isEmpty) {
      subjectQuestions.add(
        Question(
          id: '${subjectId}_sample_001',
          examId: subjectId,
          type: 'SINGLE_CHOICE',
          title: '在 $subjectId 考科架構中，下列何者為該技術領域的核心設計原則？',
          options: [
            '模組化、高可用性與階層式設計 (Hierarchical Design)',
            '全網單一廣播網域與平面網路架構',
            '完全停用所有路由協定與驗證機制',
            '強制所有流量經過未加密通道傳輸',
          ],
          correctAnswer: [0],
          explanation: '$subjectId 專業認證強調企業級的高可用性 (HA)、模組化與階層式網路拓撲架構。',
          explanationJa: '$subjectId のコア設計原則はモジュール化と高可用性です。',
          explanationZhTw: '$subjectId 核心設計原則強調高可用性、可擴展性與階層式模組化架構。',
          topic: '1.0 架構與設計基礎',
          imageUrl: null,
          isApproved: true,
          englishGrammarNotes: '核心詞彙：`Modular Design`, `High Availability (HA)`, `Hierarchical Architecture`.',
        ),
      );
    }

    // 寫入本地持久化快取
    await localCache.saveQuestions(subjectId, subjectQuestions);
    return subjectQuestions;
  }

  @override
  Future<Question?> getQuestionById(String id) async {
    final questions = await getQuestions();
    try {
      return questions.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Question>> getQuestionsByDomain(String domain) async {
    final questions = await getQuestions();
    return questions.where((q) => q.topic == domain).toList();
  }

  @override
  Future<void> saveQuestion(Question question) async {
    final questions = await getQuestions();
    final index = questions.indexWhere((q) => q.id == question.id);
    if (index >= 0) {
      questions[index] = question;
    } else {
      questions.add(question);
    }
    await localCache.saveQuestions(subjectId, questions);
    rtdbDatasource.setQuestionApproval(subjectId, question.id, question.isApproved);

    // 寫入離線佇列
    await localCache.enqueueMutation({
      'action': 'SAVE_QUESTION',
      'subjectId': subjectId,
      'question': question.toMap(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteQuestion(String id) async {
    final questions = await getQuestions();
    questions.removeWhere((q) => q.id == id);
    await localCache.saveQuestions(subjectId, questions);

    await localCache.enqueueMutation({
      'action': 'DELETE_QUESTION',
      'subjectId': subjectId,
      'questionId': id,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> approveAllQuestions() async {
    final questions = await getQuestions();
    final updated = questions.map((q) => q.copyWith(isApproved: true)).toList();
    await localCache.saveQuestions(subjectId, updated);
    rtdbDatasource.approveAllForSubject(
      subjectId,
      updated.map((q) => q.id).toList(),
    );

    await localCache.enqueueMutation({
      'action': 'APPROVE_ALL_QUESTIONS',
      'subjectId': subjectId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> setQuestionApproval(String id, bool isApproved) async {
    final question = await getQuestionById(id);
    if (question != null) {
      await saveQuestion(question.copyWith(isApproved: isApproved));
    }
  }
}
