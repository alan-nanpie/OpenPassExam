import 'package:flutter_test/flutter_test.dart';
import 'package:passexam/data/models/question.dart';

void main() {
  group('Question Model Tests', () {
    test('應該正確從 camelCase JSON 反序列化 Question', () {
      final json = {
        'id': 'q_test_101',
        'examId': 'cisco-200-301',
        'type': 'SINGLE_CHOICE',
        'title': '什麼是 OSPF 的預設管理距離？',
        'options': ['110', '90', '120', '1'],
        'correctAnswer': [0],
        'explanation': 'OSPF 的 AD 值為 110。',
        'topic': '3.0 IP Connectivity',
        'isApproved': true,
      };

      final q = Question.fromMap(json);
      expect(q.id, 'q_test_101');
      expect(q.examId, 'cisco-200-301');
      expect(q.type, 'SINGLE_CHOICE');
      expect(q.correctAnswer, [0]);
      expect(q.isApproved, true);
    });

    test('應該相容從 snake_case JSON (Firestore 原生欄位) 反序列化 Question', () {
      final json = {
        'question_id': 'q_test_snake_102',
        'exam_id': 'cisco-350-401',
        'type': 'multiple_choice',
        'question_text': '請選擇兩項 BGP 屬性：',
        'options': ['Weight', 'Local Preference', 'Hop Count'],
        'correct_answer': [0, 1],
        'explanation_zh_tw': 'BGP 使用 Weight 與 Local Preference 選路。',
        'is_approved': true,
        'topic': '3.0 Infrastructure',
      };

      final q = Question.fromMap(json);
      expect(q.id, 'q_test_snake_102');
      expect(q.examId, 'cisco-350-401');
      expect(q.type, 'MULTIPLE_CHOICE');
      expect(q.correctAnswer, [0, 1]);
      expect(q.explanationZhTw, 'BGP 使用 Weight 與 Local Preference 選路。');
      expect(q.isApproved, true);
    });
  });
}
