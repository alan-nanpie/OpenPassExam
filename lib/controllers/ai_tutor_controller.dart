import 'package:flutter/foundation.dart';
import '../data/models/question.dart';
import '../data/repositories/rag_repository.dart';
import '../services/ai_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? modelBadge;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.modelBadge,
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
        text: '👋 您好！我是您的 PassExam AI 智慧助教。\n\n我支援 **Google Gemini 3.7 Flash Dynamic Thinking** 與端側 **Gemma 4 (2B)** 雙引擎，能以「生活化通俗比喻」破題，或手把手提供 Cisco CLI 實戰指令指引！請隨時點擊考題解析或直接向我提問。',
        isUser: false,
        timestamp: DateTime.now(),
        modelBadge: 'Gemini 3.7 Flash',
      ),
    );
  }

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  AiPersona get currentPersona => _currentPersona;

  String? get userGeminiApiKey => aiService.localCache.getUserGeminiApiKey();
  bool get hasUserApiKey => userGeminiApiKey != null && userGeminiApiKey!.isNotEmpty;

  Future<void> saveUserApiKey(String key) async {
    await aiService.localCache.saveUserGeminiApiKey(key);
    notifyListeners();
  }

  Future<void> clearUserApiKey() async {
    await aiService.localCache.clearUserGeminiApiKey();
    notifyListeners();
  }

  void setPersona(AiPersona persona) {
    _currentPersona = persona;
    notifyListeners();
  }

  Future<void> sendUserMessage(String prompt, {Question? questionContext}) async {
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
      final responseText = await aiService.askAiTutor(
        prompt: prompt,
        questionContext: questionContext,
        ragChunks: chunks,
        persona: _currentPersona,
        apiKey: apiKey,
      );

      final effectiveConfig = aiService.resolveEffectiveAiConfig();
      final isOffline = await aiService.isOffline();

      _messages.add(
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
          modelBadge: (isOffline || apiKey == null || apiKey.isEmpty)
              ? 'Gemma 4 (2B)'
              : effectiveConfig.primaryModel,
        ),
      );
    } catch (e) {
      _messages.add(
        ChatMessage(
          id: 'msg_err_${DateTime.now().millisecondsSinceEpoch}',
          text: '❌ AI 推理發生錯誤，請稍後重試或切換至端側模式：$e',
          isUser: false,
          timestamp: DateTime.now(),
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
}

