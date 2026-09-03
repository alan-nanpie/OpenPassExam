import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passexam/data/datasources/local_persistent_cache.dart';
import 'package:passexam/data/datasources/rtdb_approved_keys_datasource.dart';
import 'package:passexam/data/models/question.dart';
import 'package:passexam/data/repositories/question_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late LocalPersistentCache cache;
  late RtdbApprovedKeysDatasource rtdb;
  late FirestoreQuestionRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    cache = LocalPersistentCache(prefs);
    rtdb = RtdbApprovedKeysDatasource();
    repo = FirestoreQuestionRepository(
      subjectId: 'cisco-200-301',
      localCache: cache,
      rtdbDatasource: rtdb,
    );
  });

  group('FirestoreQuestionRepository Tests', () {
    test('初始載入應優先讀取並存入 Local Persistent Cache', () async {
      expect(cache.getCachedQuestions('cisco-200-301'), isNull);

      final questions = await repo.getQuestions();
      expect(questions, isNotEmpty);

      final cached = cache.getCachedQuestions('cisco-200-301');
      expect(cached, isNotNull);
      expect(cached!.length, questions.length);
    });

    test('根據考題 ID 查詢考題', () async {
      final questions = await repo.getQuestions();
      final firstId = questions.first.id;

      final found = await repo.getQuestionById(firstId);
      expect(found, isNotNull);
      expect(found!.id, firstId);

      final notFound = await repo.getQuestionById('non_existent_id');
      expect(notFound, isNull);
    });

    test('approveAllQuestions 應將所有考題標記為 approved 並同步至 RTDB', () async {
      await repo.getQuestions();
      await repo.approveAllQuestions();

      final questions = await repo.getQuestions();
      expect(questions.every((q) => q.isApproved), isTrue);

      final isApproved = rtdb.isQuestionApproved('cisco-200-301', questions.first.id);
      expect(isApproved, isTrue);
    });

    test('儲存與更新考題', () async {
      final questions = await repo.getQuestions();
      final target = questions.first;
      final updated = Question(
        id: target.id,
        examId: target.examId,
        type: target.type,
        title: '已修改標題：${target.title}',
        options: target.options,
        correctAnswer: target.correctAnswer,
        explanation: target.explanation,
        topic: target.topic,
        isApproved: true,
      );

      await repo.saveQuestion(updated);
      final reFetched = await repo.getQuestionById(target.id);
      expect(reFetched?.title, contains('已修改標題'));
    });
  });
}
