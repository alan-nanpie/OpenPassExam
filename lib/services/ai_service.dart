import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../data/datasources/local_persistent_cache.dart';
import '../data/datasources/rtdb_approved_keys_datasource.dart';
import '../data/models/ai_model_config.dart';
import '../data/models/question.dart';
import '../data/models/rag_knowledge_chunk.dart';
import 'remote_config_service.dart';
import 'offline_model_manager.dart';
import 'ai_offline_reasoning_engine.dart';

enum AiPersona {
  friendlyTutor, // 生活化通俗比喻助教
  cliEngineer, // Cisco CLI 手把手實戰工程師
  ccieArchitect, // 業界頂尖顧問 / CCIE 首席架構專家
}

class AiService {
  final LocalPersistentCache localCache;
  final RtdbApprovedKeysDatasource rtdbDatasource;
  final RemoteConfigService remoteConfigService;
  final Connectivity connectivity;
  final OfflineModelManager? offlineModelManager;

  AiService({
    required this.localCache,
    required this.rtdbDatasource,
    required this.remoteConfigService,
    required this.connectivity,
    this.offlineModelManager,
  });

  /// 四層階層式 AI 調度解析
  AiModelConfig resolveEffectiveAiConfig() {
    // 1. 本機覆寫
    final localOverride = localCache.getLocalAiConfig();
    if (localOverride != null) {
      return localOverride;
    }

    // 2. Firebase RTDB 廣播
    final rtdbBroadcast = rtdbDatasource.getBroadcastAiConfig();
    if (rtdbBroadcast != null) {
      return rtdbBroadcast;
    }

    // 3. Firebase Remote Config
    return remoteConfigService.currentConfig;
  }

  /// 檢查是否斷網（若斷網則強制離線端側模型）
  Future<bool> isOffline() async {
    try {
      final results = await connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none)) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// 過濾 Gemini 3.8 / 3.7 Flash Dynamic Thinking 的思考標記
  String filterThinkingOutput(String rawText) {
    // 移除 <thought>...</thought> 標籤及其中內容
    final thoughtRegex = RegExp(r'<thought>[\s\S]*?<\/thought>', multiLine: true);
    var filtered = rawText.replaceAll(thoughtRegex, '').trim();

    // 移除開頭或結尾殘留的 thought 標記
    if (filtered.startsWith('thought:')) {
      final idx = filtered.indexOf('\n\n');
      if (idx >= 0) {
        filtered = filtered.substring(idx + 2).trim();
      }
    }
    return filtered;
  }

  /// 核心推理接口：實施【三層階層調度策略】
  /// 1. 第一優先：端側離線 AI 模型 (Gemma 4 2B / Chrome Built-in Nano)
  /// 2. 第二優先：雲端 Google 最新多模態模型 (Gemini 3.8 Flash)
  /// 3. 第三優先：主流最穩定備用多模態模型 (Gemini 2.5 Flash / Gemini 1.5 Pro)
  Future<String> askAiTutor({
    required String prompt,
    Question? questionContext,
    List<RagKnowledgeChunk>? ragChunks,
    AiPersona persona = AiPersona.friendlyTutor,
    String? apiKey,
    bool forceCloud = false,
  }) async {
    final offline = await isOffline();
    final config = resolveEffectiveAiConfig();
    final offlineReady = offlineModelManager?.isModelReady ?? true;
    final isPreferOffline = offlineModelManager?.preferOffline ?? config.preferOffline;
    final hasApiKey = apiKey != null && apiKey.trim().isNotEmpty;

    // === 【第 1 優先】：端側離線 AI 模型 (Gemma 4 2B / Chrome Nano) ===
    // 觸發時機：設備離線、未設定 API Key、或使用者手動勾選「優先使用離線模型」且未強制雲端
    if (offline || !hasApiKey || (!forceCloud && isPreferOffline && offlineReady)) {
      if (offlineModelManager != null && offlineModelManager!.isModelReady) {
        return await offlineModelManager!.runLocalInference(
          prompt: prompt,
          questionTitle: questionContext?.title,
          personaStyle: persona.name,
        );
      }
      return _generateOnDeviceGemmaResponse(
        prompt: prompt,
        question: questionContext,
        persona: persona,
        ragChunks: ragChunks,
      );
    }

    // === 【第 2 優先】：雲端 Google 最新 AI 多模態模型 ===
    try {
      final cloudResponse = await _callGeminiMultimodalApi(
        modelName: config.primaryModel, // 例如 gemini-3.8-flash 或 gemini-2.5-flash
        prompt: prompt,
        apiKey: apiKey.trim(),
        config: config,
        question: questionContext,
        ragChunks: ragChunks,
        persona: persona,
      );
      return filterThinkingOutput(cloudResponse);
    } catch (e) {
      // === 【第 3 優先 (備用)】：主流且最穩定多模態模型 (Gemini 2.5 Flash) ===
      try {
        final fallbackResponse = await _callGeminiMultimodalApi(
          modelName: config.fallbackModel, // 預設 gemini-2.5-flash
          prompt: prompt,
          apiKey: apiKey.trim(),
          config: config,
          question: questionContext,
          ragChunks: ragChunks,
          persona: persona,
        );
        final cleanFallback = filterThinkingOutput(fallbackResponse);
        return '🛡️ **[已自動調度備用穩定模型：${config.fallbackModel}]**\n\n$cleanFallback';
      } catch (e2) {
        // 雙雲端模型均連線失敗時，由本地智能推理引擎無縫接管，確保百分之百針對問題回答
        final localAnswer = _generateSimulatedHighQualityResponse(
          prompt: prompt,
          question: questionContext,
          ragChunks: ragChunks,
          persona: persona,
          config: config,
        );
        return '⚠️ **[雲端 API 連線異常，已由本機端側智能引擎接管推論]**\n\n$localAnswer';
      }
    }
  }

  Future<String> _callGeminiMultimodalApi({
    required String modelName,
    required String prompt,
    required String apiKey,
    required AiModelConfig config,
    Question? question,
    List<RagKnowledgeChunk>? ragChunks,
    required AiPersona persona,
  }) async {
    // 支援官方 API 模型降級清單 (防止 futuristic 模型名稱 404 Model Not Found)
    final candidateModels = <String>{
      modelName,
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
    }.toList();

    Exception? lastException;

    for (final targetModel in candidateModels) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$targetModel:generateContent?key=$apiKey',
        );

        final systemInstruction = _buildSystemInstruction(persona, ragChunks);
        final userContent = StringBuffer();
        if (question != null) {
          userContent.writeln('【考題資訊】: ${question.title}');
          userContent.writeln('【考題選項】: ${question.options.join(" | ")}');
          userContent.writeln('【官方詳解】: ${question.explanation}');
          if (question.imageUrl != null && question.imageUrl!.isNotEmpty) {
            userContent.writeln('【考題拓撲圖片連結】: ${question.imageUrl}');
          }
        }
        userContent.writeln('【學員提問】: $prompt');

        final generationConfig = <String, dynamic>{
          'temperature': config.temperature,
          'maxOutputTokens': config.maxTokens,
        };

        // 僅在具備 thinking 支援的模型中傳遞 thinkingConfig，防止 400 Bad Request
        if (targetModel.contains('thinking') && config.thinkingBudget > 0) {
          generationConfig['thinkingConfig'] = {
            'thinkingBudget': config.thinkingBudget,
          };
        }

        final body = jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': userContent.toString()}]
            }
          ],
          'systemInstruction': {
            'parts': [{'text': systemInstruction}]
          },
          'generationConfig': generationConfig,
        });

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final candidates = json['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates[0]['content']?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              return parts.map((p) => p['text'] ?? '').join('\n');
            }
          }
        }
        lastException = Exception('Gemini API Error ($targetModel): ${response.statusCode} - ${response.body}');
      } catch (e) {
        lastException = Exception('Gemini API Exception ($targetModel): $e');
      }
    }

    throw lastException ?? Exception('Gemini API 連線失敗');
  }

  String _buildSystemInstruction(AiPersona persona, List<RagKnowledgeChunk>? ragChunks) {
    final sb = StringBuffer();
    sb.writeln('你是一位頂尖的全方位認證考試與科技教學 AI 助教。請一律使用台灣繁體中文 (台灣繁體標準專業術語，如封包、路由器、交換器、拓撲、虛擬機器、容器、子網路) 回答。');
    sb.writeln('【回答核心原則】：務必直接、具體、針對學員所提出的問題進行詳細回答與推理剖析，切勿答非所問或忽略問題重點。');

    switch (persona) {
      case AiPersona.friendlyTutor:
        sb.writeln('風格：採用生活化通俗比喻破題，讓零基礎考生也能 1 秒秒懂核心觀念，再深入剖析底層原理。');
        break;
      case AiPersona.cliEngineer:
        sb.writeln('風格：著重實戰 CLI / 程式配置步驟指引，提供清晰的 config 指令與 show / 測試驗證輸出。');
        break;
      case AiPersona.ccieArchitect:
        sb.writeln('風格：以「業界頂尖顧問 / 首席架構專家」視角，分析架構設計權衡 (Trade-offs)、故障排除思維與最佳實務。');
        break;
    }

    if (ragChunks != null && ragChunks.isNotEmpty) {
      sb.writeln('\n【參考官方教科書 RAG 切片知識庫】：');
      for (final chunk in ragChunks) {
        sb.writeln('- [${chunk.bookTitle} p.${chunk.pageNumber}] ${chunk.content}');
      }
    }

    return sb.toString();
  }

  String _generateOnDeviceGemmaResponse({
    required String prompt,
    Question? question,
    required AiPersona persona,
    List<RagKnowledgeChunk>? ragChunks,
  }) {
    return AiOfflineReasoningEngine.generateResponse(
      prompt: prompt,
      question: question,
      persona: persona,
      platformDescription: offlineModelManager?.platformSupportDescription,
      ragChunks: ragChunks,
      isSimulatedCloud: false,
    );
  }

  String _generateSimulatedHighQualityResponse({
    required String prompt,
    Question? question,
    List<RagKnowledgeChunk>? ragChunks,
    required AiPersona persona,
    required AiModelConfig config,
  }) {
    return AiOfflineReasoningEngine.generateResponse(
      prompt: prompt,
      question: question,
      persona: persona,
      platformDescription: offlineModelManager?.platformSupportDescription,
      ragChunks: ragChunks,
      isSimulatedCloud: true,
    );
  }
}
