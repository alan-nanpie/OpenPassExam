import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:passexam/controllers/ai_tutor_controller.dart';
import 'package:passexam/data/datasources/local_persistent_cache.dart';
import 'package:passexam/data/datasources/rtdb_approved_keys_datasource.dart';
import 'package:passexam/data/models/question.dart';
import 'package:passexam/data/repositories/rag_repository.dart';
import 'package:passexam/services/ai_service.dart';
import 'package:passexam/services/remote_config_service.dart';
import 'package:passexam/core/utils/file_exporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AI 助教 Markdown 匯出功能測試', () {
    late AiTutorController aiCtrl;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final localCache = LocalPersistentCache(prefs);
      final rtdb = RtdbApprovedKeysDatasource();
      final remoteConfig = RemoteConfigService();
      final connectivity = Connectivity();

      final aiService = AiService(
        localCache: localCache,
        rtdbDatasource: rtdb,
        remoteConfigService: remoteConfig,
        connectivity: connectivity,
      );

      aiCtrl = AiTutorController(
        aiService: aiService,
        ragRepository: RagRepository(),
      );
    });

    test('FileExporter.generateTimestampFileName 應產生「西元年月日時分秒.md」格式', () {
      final testDate = DateTime(2026, 9, 3, 23, 15, 45);
      final fileName = FileExporter.generateTimestampFileName(testDate);

      expect(fileName, '20260903_231545.md');
      expect(fileName.endsWith('.md'), true);
      expect(fileName.length, 18); // 8位年月日 + 1底線 + 6位時分秒 + 3位.md
    });

    test('單題對話匯出 Markdown 應完整包含學員提問、考題資訊、推論模型與回答內容', () {
      final question = Question(
        id: 'q_ospf_1',
        examId: 'cisco-200-301',
        type: 'SINGLE_CHOICE',
        title: 'Which router type connects an OSPF area to another AS?',
        options: ['ABR', 'ASBR', 'Internal Router', 'Backbone Router'],
        correctAnswer: [1],
        explanation: 'ASBR connects to external AS.',
        topic: 'OSPF Routing',
        isApproved: true,
      );

      final userMsg = ChatMessage(
        id: 'user_1',
        text: '請教 ASBR 的詳細定義與在 OSPF 拓撲中的職責？',
        isUser: true,
        timestamp: DateTime(2026, 9, 3, 23, 10, 0),
      );

      final aiMsg = ChatMessage(
        id: 'ai_1',
        text: 'ASBR (Autonomous System Boundary Router) 是自治系統邊界路由器，負責宣告 Type 4/5 LSA。',
        isUser: false,
        timestamp: DateTime(2026, 9, 3, 23, 10, 2),
        modelBadge: 'gemini-2.5-flash',
        questionContext: question,
        personaStyle: 'ccieArchitect',
        failureReason: null,
      );

      final markdown = aiCtrl.generateSingleExchangeMarkdown(aiMsg, userMsg: userMsg);

      expect(markdown.contains('# 🤖 OpenPassExam AI 助教專業對話紀錄'), true);
      expect(markdown.contains('請教 ASBR 的詳細定義'), true);
      expect(markdown.contains('Which router type connects an OSPF area to another AS?'), true);
      expect(markdown.contains('gemini-2.5-flash'), true);
      expect(markdown.contains('ccieArchitect'), true);
      expect(markdown.contains('Type 4/5 LSA'), true);
    });

    test('當雲端無法使用時，匯出之 Markdown 應明確記錄具體原因明細', () {
      final aiMsg = ChatMessage(
        id: 'ai_fallback',
        text: '本地端側智能引擎接管推論內容...',
        isUser: false,
        timestamp: DateTime(2026, 9, 3, 23, 12, 0),
        modelBadge: 'Gemma 4 (2B) 接管',
        failureReason: '您設定的 Google Gemini API Key 無效或尚未啟用。',
      );

      final markdown = aiCtrl.generateSingleExchangeMarkdown(aiMsg);

      expect(markdown.contains('Gemma 4 (2B) 接管'), true);
      expect(markdown.contains('雲端無法使用具體原因'), true);
      expect(markdown.contains('您設定的 Google Gemini API Key 無效或尚未啟用。'), true);
    });

    test('匯出全部對話應產生完整匯總 Markdown，包含所有序號與對話細節', () {
      final allMd = aiCtrl.generateAllExchangesMarkdown();

      expect(allMd.contains('# 📚 OpenPassExam AI 助教完整對話紀錄匯總'), true);
      expect(allMd.contains('對話總則數'), true);
      expect(allMd.contains('對話 #1'), true);
    });
  });
}
