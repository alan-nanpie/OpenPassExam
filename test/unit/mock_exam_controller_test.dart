import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passexam/controllers/mock_exam_controller.dart';
import 'package:passexam/data/datasources/local_persistent_cache.dart';
import 'package:passexam/data/datasources/rtdb_approved_keys_datasource.dart';
import 'package:passexam/data/repositories/repository_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late LocalPersistentCache cache;
  late RtdbApprovedKeysDatasource rtdb;
  late RepositoryFactory repoFactory;
  late MockExamController mockCtrl;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    cache = LocalPersistentCache(prefs);
    rtdb = RtdbApprovedKeysDatasource();
    repoFactory = RepositoryFactory(localCache: cache, rtdbDatasource: rtdb);
    mockCtrl = MockExamController(
      repositoryFactory: repoFactory,
      localCache: cache,
    );
  });

  tearDown(() {
    mockCtrl.dispose();
  });

  group('MockExamController Tests', () {
    test('啟動模擬考應正確初始化考題與計時器', () async {
      mockCtrl.startMockExam(
        subjectId: 'cisco-200-301',
        questionCount: 3,
        durationMinutes: 30,
      );

      // 等待非同步題目載入
      await Future.delayed(const Duration(milliseconds: 100));

      expect(mockCtrl.examQuestions.length, 3);
      expect(mockCtrl.currentIndex, 0);
      expect(mockCtrl.remainingSecondsNotifier.value, 30 * 60);
      expect(mockCtrl.currentQuestion, isNotNull);
    });

    test('作答與切換選項', () async {
      mockCtrl.startMockExam(
        subjectId: 'cisco-200-301',
        questionCount: 3,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      mockCtrl.toggleOption(0);
      expect(mockCtrl.currentSelectedOptions.contains(0), isTrue);

      mockCtrl.nextQuestion();
      expect(mockCtrl.currentIndex, 1);

      mockCtrl.prevQuestion();
      expect(mockCtrl.currentIndex, 0);
    });

    test('交卷後應完成測驗、建立 Session、進行 NTP 驗證並自動歸檔錯題', () async {
      mockCtrl.startMockExam(
        subjectId: 'cisco-200-301',
        questionCount: 3,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // 故意不選任何選項，模擬全答錯
      final session = await mockCtrl.submitExam(
        subjectId: 'cisco-200-301',
        userId: 'test_user_001',
      );

      expect(mockCtrl.isExamCompleted, isTrue);
      expect(session.totalQuestions, 3);
      expect(session.correctCount, 0);
      expect(session.scorePercentage, 0.0);
      expect(session.isPassed, isFalse);

      // 驗證 NTP 防作弊標記存在
      expect(session.isNtpVerified, isNotNull);

      // 驗證錯題自動收集至 localCache 錯題本集合中
      final wrongList = cache.getWrongQuestions();
      expect(wrongList, isNotEmpty);
      expect(wrongList.length, 3);
      expect(wrongList.first.wrongCount, 1);
    });
  });
}
