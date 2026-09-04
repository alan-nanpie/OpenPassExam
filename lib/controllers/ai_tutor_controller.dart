import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../data/models/question.dart';
import '../data/repositories/rag_repository.dart';
import '../services/ai_service.dart';
import '../services/ai_debug_log_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? modelBadge;
  final Question? questionContext;
  final String? personaStyle;
  final String? failureReason;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.modelBadge,
    this.questionContext,
    this.personaStyle,
    this.failureReason,
  });
}

class AiTutorController extends ChangeNotifier {
  final AiService aiService;
  final IRagRepository ragRepository;

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  AiPersona _currentPersona = AiPersona.friendlyTutor;

  AiTutorController({
    required this.aiService,
    required this.ragRepository,
  }) {
    // 預設歡迎訊息
    _messages.add(
      ChatMessage(
        id: 'msg_welcome',
        text: '👋 您好！我是您的 PassExam AI 智慧助教。\n\n我支援【三層智慧階層調度】：\n1. ⚡ **第 1 優先**：端側 **Gemma 4 (2B) / Web Nano** 純離線極速引擎（0 延遲、零網路消耗、100% 隱私）\n2. 🚀 **第 2 優先**：Google 雲端最新 **Gemini 3.8 Flash** 多模態旗艦推論\n3. 🛡️ **第 3 備用**：主流穩定 **Gemini 3.6 Flash** 降級保證！\n\n請隨時點擊考題解析或直接向我提問。',
        isUser: false,
        timestamp: DateTime.now(),
        modelBadge: '離線優先 / Gemini 3.8 Flash',
      ),
    );
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  AiPersona get currentPersona => _currentPersona;

  String? get userGeminiApiKey => aiService.localCache.getUserGeminiApiKey();
  List<String> get userGeminiApiKeys => aiService.localCache.getUserGeminiApiKeys();
  bool get hasUserApiKey => userGeminiApiKeys.isNotEmpty;

  Future<void> saveUserApiKey(String key) async {
    await aiService.localCache.saveUserGeminiApiKey(key);
    notifyListeners();
  }

  Future<void> saveUserApiKeys(List<String> keys) async {
    await aiService.localCache.saveUserGeminiApiKeys(keys);
    notifyListeners();
  }

  Future<void> clearUserApiKey() async {
    await aiService.localCache.clearUserGeminiApiKey();
    notifyListeners();
  }

  Future<String?> testUserApiKey(String key) async {
    return await aiService.testGeminiApiKey(key);
  }

  void setPersona(AiPersona persona) {
    _currentPersona = persona;
    notifyListeners();
  }

  Future<void> sendUserMessage(String prompt, {Question? questionContext, bool? forceCloud}) async {
    if (prompt.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    try {
      // 檢索相關教材 RAG 切片
      final chunks = await ragRepository.searchChunks(prompt, limit: 3);

      final apiKey = userGeminiApiKey;
      final offlineMgr = aiService.offlineModelManager;
      final isPreferOffline = offlineMgr?.preferOffline ?? true;
      // 當使用者關閉「離線優先」開關時，視為要求使用雲端模式
      final isForceCloud = forceCloud ?? !isPreferOffline;

      final tutorResult = await aiService.askAiTutorDetailed(
        prompt: prompt,
        questionContext: questionContext,
        ragChunks: chunks,
        persona: _currentPersona,
        apiKey: apiKey,
        forceCloud: isForceCloud,
      );

      _messages.add(
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          text: tutorResult.text,
          isUser: false,
          timestamp: DateTime.now(),
          modelBadge: tutorResult.modelUsed,
          questionContext: questionContext,
          personaStyle: _currentPersona.name,
          failureReason: tutorResult.failureReason,
        ),
      );
    } catch (e) {
      _messages.add(
        ChatMessage(
          id: 'msg_err_${DateTime.now().millisecondsSinceEpoch}',
          text: '❌ AI 推理發生錯誤，請稍後重試或切換至端側模式：$e',
          isUser: false,
          timestamp: DateTime.now(),
          failureReason: e.toString(),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> explainQuestion(Question question) async {
    final prompt = '請以深入淺出的方式，為我解析這道考題：「${question.title}」的解題思路與考點核心。';
    await sendUserMessage(prompt, questionContext: question);
  }

  /// 匯出特定單一問答對話為 Markdown 字串
  String generateSingleExchangeMarkdown(ChatMessage aiMsg, {ChatMessage? userMsg}) {
    final sb = StringBuffer();
    final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(aiMsg.timestamp);

    sb.writeln('# 🤖 OpenPassExam AI 助教專業對話紀錄');
    sb.writeln('> 📅 **紀錄時間**：$timeStr\n');

    if (userMsg != null) {
      sb.writeln('## 👤 學員提問');
      sb.writeln(userMsg.text);
      sb.writeln();
    }

    if (aiMsg.questionContext != null) {
      sb.writeln('### 📝 關聯考試考題');
      sb.writeln('**題目**：${aiMsg.questionContext!.title}');
      sb.writeln('**領域**：${aiMsg.questionContext!.topic}');
      sb.writeln();
    }

    sb.writeln('## 🧠 AI 專家回答與推論規格');
    sb.writeln('- ⚡ **使用模型**：${aiMsg.modelBadge ?? "自動調度"}');
    sb.writeln('- 🎓 **專家角色規格**：${aiMsg.personaStyle ?? _currentPersona.name}');

    if (aiMsg.failureReason != null && aiMsg.failureReason!.isNotEmpty) {
      sb.writeln('- ⚠️ **雲端無法使用具體原因**：${aiMsg.failureReason}');
    } else {
      sb.writeln('- ✅ **推論狀態**：推論正常完成');
    }
    sb.writeln();

    sb.writeln('### 💬 回答內容');
    sb.writeln(aiMsg.text);
    sb.writeln();
    sb.writeln('---\n*由 OpenPassExam AI 智慧學習系統自動匯出*');

    return sb.toString();
  }

  /// 匯出全部問答對話為 Markdown 字串
  String generateAllExchangesMarkdown() {
    final sb = StringBuffer();
    final exportTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    sb.writeln('# 📚 OpenPassExam AI 助教完整對話紀錄匯總');
    sb.writeln('> 📅 **匯出時間**：$exportTime');
    sb.writeln('> 💬 **對話總則數**：${_messages.length} 則訊息\n');
    sb.writeln('---\n');

    ChatMessage? pendingUserMsg;
    int exchangeIndex = 1;

    for (final msg in _messages) {
      if (msg.isUser) {
        pendingUserMsg = msg;
      } else {
        sb.writeln('## 📌 對話 #$exchangeIndex (${DateFormat("HH:mm:ss").format(msg.timestamp)})\n');
        if (pendingUserMsg != null) {
          sb.writeln('### 👤 學員提問');
          sb.writeln(pendingUserMsg.text);
          sb.writeln();
          pendingUserMsg = null;
        }

        if (msg.questionContext != null) {
          sb.writeln('**關聯題目**：${msg.questionContext!.title} (${msg.questionContext!.topic})');
          sb.writeln();
        }

        sb.writeln('### 🧠 AI 回答');
        sb.writeln('- ⚡ **推論模型**：${msg.modelBadge ?? "自動調度"}');
        if (msg.failureReason != null && msg.failureReason!.isNotEmpty) {
          sb.writeln('- ⚠️ **雲端異常/未啟用原因明細**：${msg.failureReason}');
        }
        sb.writeln();
        sb.writeln(msg.text);
        sb.writeln('\n---\n');
        exchangeIndex++;
      }
    }

    sb.writeln('## 🛠️ 內部推論除錯日誌 (Debug Log 摘要)');
    sb.writeln('```text');
    sb.writeln(AiDebugLogService.instance.exportAllLogsAsText());
    sb.writeln('```\n');

    sb.writeln('*由 OpenPassExam AI 助教匯出系統自動產出*');
    return sb.toString();
  }

  /// 匯出純除錯日誌文字
  String exportDebugLogs() {
    return AiDebugLogService.instance.exportAllLogsAsText();
  }

  /// 清空除錯日誌
  void clearDebugLogs() {
    AiDebugLogService.instance.clear();
    notifyListeners();
  }
}

