import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passexam/data/datasources/local_persistent_cache.dart';
import 'package:passexam/data/models/question.dart';
import 'package:passexam/data/models/wrong_question.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Local Persistent Cache & Mutation Queue Tests', () {
    late LocalPersistentCache cache;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      cache = LocalPersistentCache(prefs);
    });

    test('離線時能正常存取考題快取', () async {
      final questions = [
        Question(
          id: 'q_off_01',
          examId: 'cisco-200-301',
          type: 'SINGLE_CHOICE',
          title: '離線考題測試',
          options: ['A', 'B'],
          correctAnswer: [0],
          explanation: '離線測試詳解',
          topic: '1.0 Network Fundamentals',
          isApproved: true,
        )
      ];

      await cache.saveQuestions('cisco-200-301', questions);
      final retrieved = cache.getCachedQuestions('cisco-200-301');

      expect(retrieved, isNotNull);
      expect(retrieved!.length, 1);
      expect(retrieved.first.id, 'q_off_01');
      expect(retrieved.first.title, '離線考題測試');
    });

    test('離線作答時應正確將變更排入 Mutation Queue 佇列', () async {
      expect(cache.getMutationQueue().isEmpty, true);

      await cache.enqueueMutation({
        'action': 'RECORD_ANSWER',
        'questionId': 'q_off_01',
        'isCorrect': true,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final queue = cache.getMutationQueue();
      expect(queue.length, 1);
      expect(queue.first['action'], 'RECORD_ANSWER');
      expect(queue.first['questionId'], 'q_off_01');

      await cache.clearMutationQueue();
      expect(cache.getMutationQueue().isEmpty, true);
    });

    test('錯題本快取應能正確儲存與讀取', () async {
      final wrongList = [
        WrongQuestion(
          questionId: 'q_wrong_01',
          examId: 'cisco-200-301',
          topic: '3.0 IP Connectivity',
          wrongCount: 2,
          lastWrongTime: DateTime.now(),
        ),
      ];

      await cache.saveWrongQuestions(wrongList);
      final retrieved = cache.getWrongQuestions();

      expect(retrieved.length, 1);
      expect(retrieved.first.wrongCount, 2);
      expect(retrieved.first.isMastered, false);
    });
  });
}
