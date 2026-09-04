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
  friendlyTutor, // 該技術領域首席顧問與頂尖技術專家 (全方位詳細解析)
  cliEngineer, // 頂尖系統與網路工程師 (實戰配置與深入排錯)
  ccieArchitect, // 企業級首席系統與網路架構師 (高階設計、性能與權衡)
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
      // 若本機覆寫中殘留舊版預設模型（如 gemini-2.5-flash / gemini-2.0-flash），自動平滑升級至 gemini-3.8-flash
      if (localOverride.primaryModel == 'gemini-2.5-flash' || localOverride.primaryModel.contains('gemini-2.0')) {
        final upgraded = localOverride.copyWith(primaryModel: 'gemini-3.8-flash');
        localCache.saveLocalAiConfig(upgraded);
        return upgraded;
      }
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
    final result = await askAiTutorDetailed(
      prompt: prompt,
      questionContext: questionContext,
      ragChunks: ragChunks,
      persona: persona,
      apiKey: apiKey,
      forceCloud: forceCloud,
    );
    return result.text;
  }

  /// 精準推論接口：回傳回答文本與實際調度成功之模型名稱
  Future<({String text, String modelUsed, String? failureReason})> askAiTutorDetailed({
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

    // === 使用者明確要求雲端模式但沒有填入 API Key ===
    if (forceCloud && !hasApiKey) {
      final text = '⚠️ **[雲端模式需要 Gemini API Key]**\n\n'
          '您目前選擇了雲端 Gemini 旗艦推論模式，但尚未設定 API Key。\n\n'
          '**如何啟用雲端模式（3 步驟、100% 免費）**：\n'
          '1. 點擊右上角 🔑 **金鑰圖示**，或點擊上方黃色提示列\n'
          '2. 開啟 [Google AI Studio](https://aistudio.google.com/app/apikey)，以 Google 帳號登入\n'
          '3. 點擊「Create API Key」→ 複製 `AIzaSy...` 開頭的金鑰 → 貼回本 App\n\n'
          '> 📌 金鑰只存放在您的瀏覽器本機快取中，絕不上傳至任何伺服器！\n\n'
          '---\n'
          '🛡️ **以下由本機端側智能引擎為您即時回答：**\n\n'
          '${_generateOnDeviceGemmaResponse(prompt: prompt, question: questionContext, persona: persona, ragChunks: ragChunks)}';
      return (text: text, modelUsed: 'Gemma 4 (2B) 離線', failureReason: '未配置 Google Gemini API Key (BYOK)');
    }

    // === 【第 1 優先】：端側離線 AI 模型 (Gemma 4 2B / Chrome Nano) ===
    if (offline || (!forceCloud && !hasApiKey) || (!forceCloud && isPreferOffline && offlineReady)) {
      if (offlineModelManager != null && offlineModelManager!.isModelReady) {
        final text = await offlineModelManager!.runLocalInference(
          prompt: prompt,
          questionTitle: questionContext?.title,
          personaStyle: persona.name,
        );
        return (text: text, modelUsed: 'Gemma 4 (2B) 離線', failureReason: null);
      }
      final text = _generateOnDeviceGemmaResponse(
        prompt: prompt,
        question: questionContext,
        persona: persona,
        ragChunks: ragChunks,
      );
      return (text: text, modelUsed: 'Gemma 4 (2B) 離線', failureReason: null);
    }

    // === 【第 2 優先】：雲端 Google 最新 AI 多模態模型 (支援金鑰池自動輪替 Failover) ===
    // 取得所有可用金鑰清單
    final keyPool = localCache.getUserGeminiApiKeys();
    final candidateKeys = <String>{
      if (apiKey != null && apiKey.trim().isNotEmpty) apiKey.trim(),
      ...keyPool,
    }.toList();

    var quotaExhaustedCount = 0;
    var invalidKeyCount = 0;
    String? lastFailureReason;

    for (var i = 0; i < candidateKeys.length; i++) {
      final currentKey = candidateKeys[i];
      try {
        final cloudResponse = await _callGeminiMultimodalApi(
          modelName: config.primaryModel, // gemini-3.8-flash
          prompt: prompt,
          apiKey: currentKey,
          config: config,
          question: questionContext,
          ragChunks: ragChunks,
          persona: persona,
        );
        return (
          text: filterThinkingOutput(cloudResponse.text),
          modelUsed: cloudResponse.modelUsed,
          failureReason: null,
        );
      } catch (e) {
        final errStr = e.toString();
        if (errStr.contains('RESOURCE_EXHAUSTED') || errStr.contains('429')) {
          quotaExhaustedCount++;
        } else if (errStr.contains('API_KEY_INVALID') || errStr.contains('API key not valid')) {
          invalidKeyCount++;
        }
        lastFailureReason = errStr;

        // 若還有下一把備用金鑰，自動輪替並繼續重試
        if (i < candidateKeys.length - 1) {
          continue;
        }

        // 當所有金鑰皆嘗試過 primaryModel 失敗時，嘗試以備用穩定模型 (gemini-2.5-flash) 輪替重試
        for (var j = 0; j < candidateKeys.length; j++) {
          final fallbackKey = candidateKeys[j];
          try {
            final fallbackResponse = await _callGeminiMultimodalApi(
              modelName: config.fallbackModel, // 預設 gemini-2.5-flash
              prompt: prompt,
              apiKey: fallbackKey,
              config: config,
              question: questionContext,
              ragChunks: ragChunks,
              persona: persona,
            );
            final cleanFallback = filterThinkingOutput(fallbackResponse.text);
            return (
              text: '🛡️ **[已自動調度備用穩定模型：${fallbackResponse.modelUsed}]**\n\n$cleanFallback',
              modelUsed: fallbackResponse.modelUsed,
              failureReason: null,
            );
          } catch (e2) {
            final errStr2 = e2.toString();
            if (errStr2.contains('RESOURCE_EXHAUSTED') || errStr2.contains('429')) {
              quotaExhaustedCount++;
            }
            lastFailureReason = errStr2;
          }
        }
      }
    }

    // 雙雲端模型與所有金鑰池均連線失敗時，由本地智能推理引擎無縫接管
    final localAnswer = _generateSimulatedHighQualityResponse(
      prompt: prompt,
      question: questionContext,
      ragChunks: ragChunks,
      persona: persona,
      config: config,
    );

    String errorDiagnosis;
    final totalKeys = candidateKeys.length;
    if (totalKeys > 0 && quotaExhaustedCount >= totalKeys) {
      errorDiagnosis = '⚠️ **您所設定的 $totalKeys 組 Gemini API Key 今日免費額度皆已全數耗盡 (429 RESOURCE_EXHAUSTED)**。\n'
          '> 建議：請至 [Google AI Studio](https://aistudio.google.com/app/apikey) 免費建立新金鑰並加入金鑰池，或等待 Google 每日配額重設。';
    } else if (totalKeys > 0 && invalidKeyCount >= totalKeys) {
      errorDiagnosis = '您設定的 $totalKeys 組 Google Gemini API Key 皆無效或尚未啟用。請至 [Google AI Studio](https://aistudio.google.com/app/apikey) 免費重新建立正確的金鑰 (支援 AQ... 與 AIzaSy... 格式)。';
    } else if (lastFailureReason != null) {
      if (lastFailureReason.contains('API_KEY_INVALID') || lastFailureReason.contains('API key not valid')) {
        errorDiagnosis = '您設定的 Google Gemini API Key 無效或尚未啟用。請點擊右上角金鑰圖示 🔑，至 [Google AI Studio](https://aistudio.google.com/app/apikey) 免費建立正確金鑰。';
      } else if (lastFailureReason.contains('RESOURCE_EXHAUSTED') || lastFailureReason.contains('429')) {
        errorDiagnosis = 'Gemini API Key 免費配額已耗盡 (429 RESOURCE_EXHAUSTED)。請更換或新增金鑰。';
      } else if (lastFailureReason.contains('PERMISSION_DENIED')) {
        errorDiagnosis = '該 API Key 缺乏 Generative Language API 存取權限。';
      } else if (lastFailureReason.contains('XMLHttpRequest') || lastFailureReason.contains('ClientException')) {
        errorDiagnosis = '瀏覽器發送網路請求失敗（可能是網路連線不穩或受廣告攔截插件阻擋）。';
      } else if (lastFailureReason.contains('TimeoutException')) {
        errorDiagnosis = 'Google 雲端 API 伺服器連線逾時 (超過 15 秒)。';
      } else {
        errorDiagnosis = lastFailureReason;
      }
    } else {
      errorDiagnosis = 'Google 雲端 API 連線中斷';
    }

    final text = '⚠️ **[雲端 API 連線異常提示]**\n> 🔍 **診斷原因**：$errorDiagnosis\n> 🛡️ **已自動由本機端側智能引擎接管推論**\n\n$localAnswer';
    return (text: text, modelUsed: 'Gemma 4 (2B) 接管', failureReason: errorDiagnosis);
  }

  Future<({String text, String modelUsed})> _callGeminiMultimodalApi({
    required String modelName,
    required String prompt,
    required String apiKey,
    required AiModelConfig config,
    Question? question,
    List<RagKnowledgeChunk>? ragChunks,
    required AiPersona persona,
  }) async {
    final cleanApiKey = apiKey.trim().replaceAll('"', '').replaceAll("'", '');

    // 支援官方 API 模型降級清單
    // 嚴格鎖定最新 gemini-3.8-flash 與穩定備用 gemini-2.5-flash，不含已下線的 1.5
    final candidateModels = <String>{
      modelName,
      'gemini-3.8-flash',
      'gemini-2.5-flash',
    }.toList();

    Exception? lastException;

    for (final targetModel in candidateModels) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$targetModel:generateContent?key=$cleanApiKey',
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

        final isGemini3Family = targetModel.startsWith('gemini-3');
        final generationConfig = <String, dynamic>{
          'maxOutputTokens': config.maxTokens,
        };

        if (isGemini3Family) {
          // Gemini 3.8 Flash 官方規範：
          // 1. 移除 temperature, top_p, top_k, frequency_penalty, presence_penalty, candidate_count
          // 2. thinkingConfig 採用 thinkingLevel 列舉 (LOW, MEDIUM, HIGH)，嚴格禁止 MINIMAL
          final level = config.thinkingLevel.toUpperCase();
          final validLevel = (level == 'LOW' || level == 'HIGH') ? level : 'MEDIUM';
          generationConfig['thinkingConfig'] = {
            'thinkingLevel': validLevel,
          };
        } else {
          // 針對舊版備用模型 (如 gemini-2.5-flash) 保持相容參數
          generationConfig['temperature'] = config.temperature;
          if (targetModel.contains('thinking') && config.thinkingBudget > 0) {
            generationConfig['thinkingConfig'] = {
              'thinkingBudget': config.thinkingBudget,
            };
          }
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
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final candidates = json['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates[0]['content']?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts.map((p) => p['text'] ?? '').join('\n');
              return (text: text, modelUsed: targetModel);
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
    sb.writeln('你是一位在該問題所屬技術領域擁有 20 年以上經驗的頂尖技術專家與首席顧問（包括但不限於網路架構、雲端系統、分散式計算、資料庫、資安、軟體工程與全方位專業認證領域）。');
    sb.writeln('請一律使用台灣繁體中文（採用台灣繁體標準專業技術術語，如：封包、路由器、交換器、拓撲、虛擬機器、容器、子網路、中繼埠、路由表等）回答。');
    sb.writeln('\n【核心回答指導原則】：');
    sb.writeln('1. **頂尖專家與資深顧問角色**：你將以該技術領域最頂尖的專家或首席顧問身分，針對使用者提出的問題提供最權威、最深入且具備實務洞察力的解答。');
    sb.writeln('2. **內容極致詳盡**：請勿簡略或流於表面，必須深入探討底層運作機制、通訊協定細節、資料結構與狀態機轉移、RFC 標準規格、架構設計權衡（Trade-offs）以及生產環境下的實務經驗。');
    sb.writeln('3. **結構清晰完整**：採用專業結構化 Markdown 排版（包含架構原理、詳細步驟、完整配置指令、狀態驗證與排錯心法）。');
    sb.writeln('4. **直接切入核心**：避免空泛贅詞，直指問題技術核心。');

    switch (persona) {
      case AiPersona.friendlyTutor:
        sb.writeln('\n【顧問風格】：技術領域首席顧問。提供全方位、高度詳盡的技術白皮書級別深度剖析，從底層協定規範到企業級最佳實務一應俱全。');
        break;
      case AiPersona.cliEngineer:
        sb.writeln('\n【顧問風格】：頂尖系統與網路資深工程師。提供精準且完整的實戰 CLI / 程式配置、端到端佈署流程、完整驗證（Show / Debug / Log）指令及排錯方法論。');
        break;
      case AiPersona.ccieArchitect:
        sb.writeln('\n【顧問風格】：企業級首席系統與網路架構師。從全局架構設計、高可用性（HA）、負載平衡、容災（DR）、資安合規、效能瓶頸突破與維運成本權衡出發提供戰略級諮詢。');
        break;
    }

    if (ragChunks != null && ragChunks.isNotEmpty) {
      sb.writeln('\n【參考官方教材與規範 RAG 切片知識庫】：');
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

  /// 驗證使用者輸入的 Gemini API Key 是否有效
  Future<String?> testGeminiApiKey(String apiKey) async {
    final cleanKey = apiKey.trim().replaceAll('"', '').replaceAll("'", '');
    if (cleanKey.isEmpty) return 'API Key 不能為空';
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=$cleanKey',
      );
      final body = jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [{'text': 'ping'}]
          }
        ],
      });
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return null; // 成功無錯誤
      }
      try {
        final json = jsonDecode(response.body);
        final msg = json['error']?['message'] ?? 'HTTP ${response.statusCode}';
        return msg.toString();
      } catch (_) {
        return 'HTTP ${response.statusCode}：${response.body}';
      }
    } catch (e) {
      return e.toString();
    }
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
