import 'package:flutter_test/flutter_test.dart';
import 'package:passexam/services/ai_service.dart';
import 'package:passexam/services/ai_offline_reasoning_engine.dart';
import 'package:passexam/data/models/question.dart';

void main() {
  group('AI 離線動態推理引擎 (AiOfflineReasoningEngine) 測試', () {
    test('能夠針對學員提出的打招呼問題，給予親切指引與功能介紹', () {
      final response = AiOfflineReasoningEngine.generateResponse(
        prompt: '你好，請介紹一下你自己',
        persona: AiPersona.friendlyTutor,
      );

      expect(response.contains('PassExam'), true);
      expect(response.contains('針對您的提問'), true);
      expect(response.contains('端側 Gemma 4 (2B)'), true);
    });

    test('能夠針對學員提出的子網路計算問題，給予精確公式與 /24 計算', () {
      final response = AiOfflineReasoningEngine.generateResponse(
        prompt: '請問子網路 /24 可以容納多少台可用主機？',
        persona: AiPersona.cliEngineer,
      );

      expect(response.contains('子網路'), true);
      expect(response.contains('254'), true);
      expect(response.contains('2^(32 - n) - 2'), true);
      expect(response.contains('Device# configure terminal'), true);
    });

    test('能夠針對學員提出的 VLAN 問題，結合 Persona 給予隔音玻璃帷幕比喻與交換器說明', () {
      final response = AiOfflineReasoningEngine.generateResponse(
        prompt: '什麼是 VLAN？它有什麼好處？',
        persona: AiPersona.friendlyTutor,
      );

      expect(response.contains('VLAN'), true);
      expect(response.contains('廣播網域'), true);
      expect(response.contains('隔音玻璃帷幕'), true);
    });

    test('能夠針對學員提出的雲端運算 (AWS/GCP) 問題，給予架構設計分析', () {
      final response = AiOfflineReasoningEngine.generateResponse(
        prompt: '請問 AWS S3 與 Cloud Run 的使用場景是什麼？',
        persona: AiPersona.ccieArchitect,
      );

      expect(response.contains('雲端'), true);
      expect(response.contains('無伺服器與容器化'), true);
      expect(response.contains('CCIE 首席架構設計'), true);
    });

    test('當有考題上下文時，解答能包含考題題目與選項解析', () {
      final question = Question(
        id: 'q_test_1',
        examId: 'cisco-200-301',
        type: 'SINGLE_CHOICE',
        title: 'Which protocol operates at Layer 3 of the OSI model?',
        options: ['Ethernet', 'IP', 'TCP', 'HTTP'],
        correctAnswer: [1],
        explanation: 'IP (Internet Protocol) operates at Layer 3.',
        topic: 'Network Fundamentals',
        isApproved: true,
      );

      final response = AiOfflineReasoningEngine.generateResponse(
        prompt: '為什麼這題選 B 而不是 C？',
        question: question,
        persona: AiPersona.friendlyTutor,
      );

      expect(response.contains('Which protocol operates at Layer 3'), true);
      expect(response.contains('IP'), true);
      expect(response.contains('TCP'), true);
    });

    test('當學員詢問「OSPF 指令」時，引擎能完整輸出 Cisco 配置與 show ip ospf neighbor 排錯指令', () {
      final response = AiOfflineReasoningEngine.generateResponse(
        prompt: 'OSPF 指令',
        persona: AiPersona.friendlyTutor,
      );

      expect(response.contains('OSPF'), true);
      expect(response.contains('router ospf'), true);
      expect(response.contains('network'), true);
      expect(response.contains('show ip ospf neighbor'), true);
      expect(response.contains('show ip route ospf'), true);
      expect(response.contains('Area 0'), true);
    });
  });
}
