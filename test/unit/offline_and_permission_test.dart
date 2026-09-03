import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:passexam/data/datasources/local_persistent_cache.dart';
import 'package:passexam/data/datasources/rtdb_approved_keys_datasource.dart';
import 'package:passexam/data/models/question.dart';
import 'package:passexam/data/models/question_comment.dart';
import 'package:passexam/data/repositories/question_repository.dart';
import 'package:passexam/data/repositories/discussion_repository.dart';
import 'package:passexam/services/ai_service.dart';
import 'package:passexam/services/remote_config_service.dart';
import 'package:passexam/services/offline_model_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('離線 AI 模型與多平台調度測試', () {
    late SharedPreferences prefs;
    late LocalPersistentCache localCache;
    late OfflineModelManager offlineManager;
    late AiService aiService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      localCache = LocalPersistentCache(prefs);
      offlineManager = OfflineModelManager(prefs);
      aiService = AiService(
        localCache: localCache,
        rtdbDatasource: RtdbApprovedKeysDatasource(),
        remoteConfigService: RemoteConfigService(),
        connectivity: Connectivity(),
        offlineModelManager: offlineManager,
      );
    });

    test('離線模型管理器狀態與下載流程測試', () async {
      expect(offlineManager.preferOffline, true);
      // 執行下載
      await offlineManager.downloadModel();
      expect(offlineManager.isModelReady, true);
      expect(offlineManager.downloadProgress, 1.0);

      // 測試本地推論輸出
      final result = await offlineManager.runLocalInference(
        prompt: '請說明 VLAN 概念',
        questionTitle: 'VLAN 考題',
      );
      expect(result.contains('端側 Gemma 4 (2B)'), true);
      expect(result.contains('第 1 優先模式'), true);

      // 刪除模型
      await offlineManager.deleteModel();
      expect(offlineManager.status, OfflineModelStatus.notDownloaded);
    });

    test('AiService 三層調度：第 1 優先應執行端側離線推論', () async {
      await offlineManager.downloadModel();

      final response = await aiService.askAiTutor(
        prompt: '請問路由器的作用為何？',
      );
      // 預設 preferOffline = true，應走第 1 優先離線模式
      expect(response.contains('端側 Gemma 4 (2B)'), true);
    });
  });

  group('考題與討論區多使用者 CRUD 與所有權限隔離測試', () {
    late SharedPreferences prefs;
    late LocalPersistentCache localCache;
    late FirestoreQuestionRepository questionRepo;
    late DiscussionRepository discussionRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      localCache = LocalPersistentCache(prefs);
      questionRepo = FirestoreQuestionRepository(
        subjectId: 'cisco-200-301',
        localCache: localCache,
        rtdbDatasource: RtdbApprovedKeysDatasource(),
      );
      discussionRepo = DiscussionRepository(localCache: localCache);
    });

    test('考題建立者擁有 CRUD 權限，非建立者僅能 Read', () async {
      final userA = 'user_author_001';
      final userB = 'user_viewer_002';

      final userAQuestion = Question(
        id: 'q_custom_001',
        examId: 'cisco-200-301',
        type: 'SINGLE_CHOICE',
        title: 'User A 創建的私有考題',
        options: ['A', 'B'],
        correctAnswer: [0],
        explanation: 'A 詳解',
        topic: '1.0 基礎',
        isApproved: true,
        creatorId: userA,
        creatorName: 'Alice',
      );

      // 1. User A 建立考題 (Create)
      await questionRepo.saveQuestion(userAQuestion, currentUserId: userA);

      // 2. User B 可以讀取考題 (Read)
      final fetched = await questionRepo.getQuestionById('q_custom_001');
      expect(fetched != null, true);
      expect(fetched!.title, 'User A 創建的私有考題');
      expect(fetched.isOwner(userA), true);
      expect(fetched.isOwner(userB), false);

      // 3. User B 嘗試修改 User A 的考題 (Update) -> 應被拒絕
      final modifiedQuestion = fetched.copyWith(title: 'User B 惡意修改標題');
      expect(
        () async => await questionRepo.saveQuestion(modifiedQuestion, currentUserId: userB),
        throwsA(isA<Exception>()),
      );

      // 4. User B 嘗試刪除 User A 的考題 (Delete) -> 應被拒絕
      expect(
        () async => await questionRepo.deleteQuestion('q_custom_001', currentUserId: userB),
        throwsA(isA<Exception>()),
      );

      // 5. User A 本人修改與刪除 -> 成功
      await questionRepo.saveQuestion(
        fetched.copyWith(title: 'User A 正常修改標題'),
        currentUserId: userA,
      );
      final updated = await questionRepo.getQuestionById('q_custom_001');
      expect(updated!.title, 'User A 正常修改標題');

      await questionRepo.deleteQuestion('q_custom_001', currentUserId: userA);
      final deleted = await questionRepo.getQuestionById('q_custom_001');
      expect(deleted, null);
    });

    test('考題討論區留言：僅原作者或管理員可修改/刪除留言，其他人唯讀', () async {
      const qId = 'ccna_q001';
      const userAlice = 'user_alice';
      const userBob = 'user_bob';

      final aliceComment = QuestionComment(
        id: 'comment_alice_01',
        questionId: qId,
        examId: 'cisco-200-301',
        authorId: userAlice,
        authorName: 'Alice',
        content: 'Alice 對這題的心得',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1. Alice 新增留言 (Create)
      await discussionRepo.addComment(aliceComment);

      final comments = await discussionRepo.getComments(qId);
      final found = comments.firstWhere((c) => c.id == 'comment_alice_01');
      expect(found.isAuthor(userAlice), true);
      expect(found.isAuthor(userBob), false);

      // 2. Bob 嘗試篡改 Alice 的留言 (Update) -> 拋出異常
      expect(
        () async => await discussionRepo.updateComment(
          found.copyWith(content: 'Bob 篡改內容'),
          currentUserId: userBob,
        ),
        throwsA(isA<Exception>()),
      );

      // 3. Bob 嘗試刪除 Alice 的留言 (Delete) -> 拋出異常
      expect(
        () async => await discussionRepo.deleteComment(
          'comment_alice_01',
          qId,
          currentUserId: userBob,
        ),
        throwsA(isA<Exception>()),
      );

      // 4. Alice 本人更新與刪除 -> 成功
      await discussionRepo.updateComment(
        found.copyWith(content: 'Alice 更新後的心得'),
        currentUserId: userAlice,
      );
      final updatedComments = await discussionRepo.getComments(qId);
      expect(
        updatedComments.firstWhere((c) => c.id == 'comment_alice_01').content,
        'Alice 更新後的心得',
      );

      await discussionRepo.deleteComment(
        'comment_alice_01',
        qId,
        currentUserId: userAlice,
      );
      final finalComments = await discussionRepo.getComments(qId);
      expect(finalComments.any((c) => c.id == 'comment_alice_01'), false);
    });
  });
}
